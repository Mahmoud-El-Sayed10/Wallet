document.addEventListener('DOMContentLoaded', () => {
    console.log('Page loaded');
    const userId = sessionStorage.getItem('user_id');
    const navbar = document.querySelector('.navbar');

    // Update navbar based on login status
    if (navbar) {
        const navLinksContainer = document.getElementById('navLinks') || document.querySelector('.nav-links');
        if (navLinksContainer) {
            if (userId) {
                navLinksContainer.innerHTML = `
                    <li><a href="dashboard.html">Dashboard</a></li>
                    <li><a href="#transactions">Transactions</a></li>
                    <li><a href="profile.html">Profile</a></li>
                    <li><a href="#" id="signOut">Sign Out</a></li>
                    <li><a href="#wallets">Wallets</a></li>
                `;
            } else {
                navLinksContainer.innerHTML = `
                    <li><a href="../index.html#features">Features</a></li>
                    <li><a href="../index.html#about">About</a></li>
                    <li><a href="../index.html#contact">Contact</a></li>
                `;
            }
        }
    }

    // Smooth scrolling for navigation links
    const navLinks = document.querySelectorAll('.nav-links a');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const href = link.getAttribute('href');
            const sectionId = href.startsWith('../') ? href.substring(2) : href;
            const section = document.getElementById(sectionId.replace('#', ''));
            if (section) {
                section.scrollIntoView({ behavior: 'smooth' });
            } else {
                console.warn(`Section ${sectionId} not found`);
            }
        });
    });

    const img = document.querySelector('.about-image');
    if (img) {
        if (!img.complete) {
            img.style.opacity = '0';
            img.onload = () => (img.style.transition = 'opacity 0.5s', img.style.opacity = '1');
            img.onerror = () => (img.style.display = 'none', console.error('Image failed to load'));
        }
    } else {
        console.warn('About image not found');
    }

    const buttons = document.querySelectorAll('.btn');
    if (buttons.length > 0) {
        buttons.forEach(btn => {
            btn.addEventListener('mouseover', () => btn.style.animationPlayState = 'paused');
            btn.addEventListener('mouseout', () => btn.style.animationPlayState = 'running');
        });
    } else {
        console.warn('No buttons found with class .btn');
    }

    // Password Visibility Toggle
    const showPasswordCheckbox = document.getElementById('showPassword');
    const passwordField = document.getElementById('userPassword');
    if (showPasswordCheckbox && passwordField) {
        showPasswordCheckbox.addEventListener('change', () => {
            passwordField.type = showPasswordCheckbox.checked ? 'text' : 'password';
        });
    }

    // Login API Integration with JSON
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = document.getElementById('userEmail').value.trim();
            const password = document.getElementById('userPassword').value.trim();

            if (!email || !password) {
                showResult('Please enter both email and password', 'error');
                document.getElementById('userPassword').value = '';
                return;
            }

            try {
                const res = await axios.post('http://localhost/Wallet/Wallet - Server/user/v1/login.php', JSON.stringify({
                    email,
                    password
                }), {
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
                if (res.data.success) {
                    sessionStorage.setItem('user_id', res.data.user_id);
                    showResult('Login successful', 'success');
                    document.getElementById('userPassword').value = '';
                    setTimeout(() => window.location.href = 'dashboard.html', 1000);
                } else {
                    showResult(res.data.message || 'Login failed', 'error');
                    document.getElementById('userPassword').value = '';
                }
            } catch (error) {
                showResult(error.response?.data?.error || 'An error occurred. Please try again.', 'error');
                document.getElementById('userPassword').value = '';
            }
        });
    }

    // Sign Out Functionality
    const signOutLink = document.getElementById('signOut');
    if (signOutLink) {
        signOutLink.addEventListener('click', (e) => {
            e.preventDefault();
            sessionStorage.removeItem('user_id');
            window.location.href = 'login.html';
        });
    }

    // Display User Info on Dashboard
    if (document.querySelector('.dashboard-section')) {
        const userIdSpan = document.getElementById('userId');
        const userEmailSpan = document.getElementById('userEmail');
        if (userId && userIdSpan && userEmailSpan) {
            userIdSpan.textContent = userId;
            // Fetch email from API
            axios.get(`http://localhost/Wallet/Wallet - Server/user/v1/getUserDetails.php?id=${userId}`, {
                headers: {
                    'Content-Type': 'application/json'
                }
            }).then(res => {
                if (res.data.success) {
                    userEmailSpan.textContent = res.data.data.email;
                } else {
                    userEmailSpan.textContent = 'Unknown';
                }
            }).catch(error => {
                console.error('Error fetching user details:', error);
                userEmailSpan.textContent = 'Unknown';
            });
        }
    }

    // Utility Function for Result Display
    function showResult(message, type) {
        const resultDiv = document.getElementById('loginResult') || document.getElementById('result');
        if (resultDiv) {
            resultDiv.innerText = message;
            resultDiv.style.color = type === 'success' ? '#28a745' : '#d9534f';
        } else {
            console.error('Result div not found');
        }
    }
});