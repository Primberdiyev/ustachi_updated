"""Admin panel jadvallari uchun sahifalash."""

from collections import OrderedDict

from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response


class AdminPagination(PageNumberPagination):
    """
    Standart DRF sahifalashiga `total_pages`, `page` va `page_size`
    qo'shadi — jadval komponenti sahifalar sonini o'zi hisoblab
    o'tirmasligi uchun.
    """

    page_size = 25
    page_size_query_param = "page_size"
    max_page_size = 200

    def get_paginated_response(self, data):
        return Response(
            OrderedDict(
                [
                    ("count", self.page.paginator.count),
                    ("total_pages", self.page.paginator.num_pages),
                    ("page", self.page.number),
                    ("page_size", self.get_page_size(self.request)),
                    ("next", self.get_next_link()),
                    ("previous", self.get_previous_link()),
                    ("results", data),
                ]
            )
        )

    def get_paginated_response_schema(self, schema):
        """OpenAPI: frontend tipli client shu shaklga tayanadi."""
        return {
            "type": "object",
            "required": ["count", "total_pages", "page", "page_size", "results"],
            "properties": {
                "count": {"type": "integer", "example": 137},
                "total_pages": {"type": "integer", "example": 6},
                "page": {"type": "integer", "example": 1},
                "page_size": {"type": "integer", "example": 25},
                "next": {"type": "string", "nullable": True, "format": "uri"},
                "previous": {"type": "string", "nullable": True, "format": "uri"},
                "results": schema,
            },
        }
