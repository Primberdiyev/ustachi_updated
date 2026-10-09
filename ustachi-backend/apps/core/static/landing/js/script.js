const area = document.querySelector('#area');
const areaValue = document.querySelector('#areaValue');
const service = document.querySelector('#service');
const estimate = document.querySelector('#estimate');

function updateEstimate() {
    const squareMeters = Number(area.value);
    const multiplier = Number(service.value);
    const price = Math.round((125000 * squareMeters * multiplier) / 50000) * 50000;
    areaValue.textContent = `${squareMeters} m²`;
    estimate.innerHTML = `${price.toLocaleString('uz-UZ')} <i>so'mdan</i>`;
}

area.addEventListener('input', updateEstimate);
service.addEventListener('change', updateEstimate);
updateEstimate();

document.querySelectorAll('a[href^="#"]').forEach((link) => {
    link.addEventListener('click', (event) => {
        const target = document.querySelector(link.getAttribute('href'));
        if (!target) return;
        event.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
});
