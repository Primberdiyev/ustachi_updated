"""
Ustaning O'Z buyurtmalari — `/api/v1/master/my-orders/`.

Bu marketplace EMAS: buyurtmachi ilovaga kirmagan, e'lon yo'q, taklif yo'q.
Usta chizmani chizadi va mijozning ma'lumotini yozib buyurtmani o'ziga
saqlab qo'yadi.

XAVFSIZLIK: queryset DOIM `filter(master=request.user)` — boshqa ustaning
buyurtmasi hech qachon ko'rinmaydi va `404` qaytadi (mavjudligi ham sir).
"""

from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import status as http
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.orders.api.v1.master_views import IsMaster
from apps.orders.api.v1.own_order_serializers import (
    MasterOrderSerializer,
    MasterOrderStatusSerializer,
)
from apps.orders.models import MasterOrder, MasterOrderStatus


def _queryset(user):
    return (
        MasterOrder.objects.filter(master=user)
        .prefetch_related("items")
    )


class MasterOwnOrderListCreateView(APIView):
    """Ro'yxat (`?status=` bilan filtr) va yangi buyurtma yaratish."""

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = MasterOrderSerializer

    def get(self, request):
        orders = _queryset(request.user)
        status_filter = request.query_params.get("status")
        if status_filter:
            orders = orders.filter(status=status_filter)
        return Response(MasterOrderSerializer(orders, many=True).data)

    def post(self, request):
        serializer = MasterOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = serializer.save(master=request.user)
        return Response(
            MasterOrderSerializer(order).data, status=http.HTTP_201_CREATED
        )


class MasterOwnOrderDetailView(APIView):
    """Bitta buyurtma: ko'rish, to'liq/qisman tahrirlash, o'chirish."""

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = MasterOrderSerializer

    def get(self, request, pk):
        order = get_object_or_404(_queryset(request.user), pk=pk)
        return Response(MasterOrderSerializer(order).data)

    def put(self, request, pk):
        return self._save(request, pk, partial=False)

    def patch(self, request, pk):
        return self._save(request, pk, partial=True)

    def delete(self, request, pk):
        order = get_object_or_404(_queryset(request.user), pk=pk)
        order.delete()
        return Response(status=http.HTTP_204_NO_CONTENT)

    def _save(self, request, pk, *, partial):
        order = get_object_or_404(_queryset(request.user), pk=pk)
        serializer = MasterOrderSerializer(order, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        return Response(MasterOrderSerializer(serializer.save()).data)


class MasterOwnOrderStatusView(APIView):
    """
    Holatni o'zgartirish. `done` ga o'tganda yakunlanish vaqti qo'yiladi,
    undan qaytsa — olib tashlanadi (usta xato bosgan bo'lishi mumkin).
    """

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = MasterOrderStatusSerializer

    def post(self, request, pk):
        order = get_object_or_404(_queryset(request.user), pk=pk)
        serializer = MasterOrderStatusSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        order.status = serializer.validated_data["status"]
        order.completed_at = (
            timezone.now() if order.status == MasterOrderStatus.DONE else None
        )
        order.save(update_fields=["status", "completed_at", "modified_at"])
        return Response(MasterOrderSerializer(order).data)
