document.addEventListener('DOMContentLoaded', () => {
    console.log('Landing page loaded');
    const navLinks = document.querySelectorAll('.nav-links a');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const sectionId = link.getAttribute('href').substring(1);
            document.getElementById(sectionId).scrollIntoView({ behavior: 'smooth' });
        });
    });

    const img = document.querySelector('.about-image');
    if (img && !img.complete) {
        img.style.opacity = '0';
        img.onload = () => (img.style.transition = 'opacity 0.5s', img.style.opacity = '1');
        img.onerror = () => img.style.display = 'none';
    }

    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(btn => {
        btn.addEventListener('mouseover', () => btn.style.animationPlayState = 'paused');
        btn.addEventListener('mouseout', () => btn.style.animationPlayState = 'running');
    });
});