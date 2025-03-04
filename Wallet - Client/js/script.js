// walletAPI.js - Centralized API service for Digital Wallet

const walletAPI = {
    // Base configuration
    baseURL: 'http://localhost/Wallet/Wallet - Server/user/v1/',
    
    // Axios default config
    init() {
        // Set default headers and configurations
        axios.defaults.withCredentials = true;
        axios.defaults.headers.common['Content-Type'] = 'application/json';
    },
    
    // Utility methods
    async get(endpoint, params = {}) {
        try {
            const response = await axios.get(`${this.baseURL}${endpoint}`, { params });
            return response.data;
        } catch (error) {
            this.handleError(error);
            throw error;
        }
    },
    
    async post(endpoint, data = {}) {
        try {
            const response = await axios.post(`${this.baseURL}${endpoint}`, data);
            return response.data;
        } catch (error) {
            this.handleError(error);
            throw error;
        }
    },
    
    async delete(endpoint, data = {}) {
        try {
            const response = await axios.delete(`${this.baseURL}${endpoint}`, { data });
            return response.data;
        } catch (error) {
            this.handleError(error);
            throw error;
        }
    },
    
    async upload(endpoint, formData) {
        try {
            const response = await axios.post(`${this.baseURL}${endpoint}`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            return response.data;
        } catch (error) {
            this.handleError(error);
            throw error;
        }
    },
    
    handleError(error) {
        // Log errors
        console.error('API Error:', error);
        
        // Handle authentication errors
        if (error.response && error.response.status === 401) {
            sessionStorage.removeItem('user_id');
            window.location.href = 'login.html';
            return;
        }
        
        // Return error message for UI display
        const errorMessage = error.response?.data?.message || 'An unexpected error occurred';
        return errorMessage;
    },
    
    // Authentication APIs
    auth: {
        async login(email, password) {
            return walletAPI.post('login.php', { email, password });
        },
        
        async logout() {
            sessionStorage.removeItem('user_id');
            return { success: true, message: 'Logged out successfully' };
        },
        
        async updatePassword(currentPassword, newPassword) {
            return walletAPI.post('updatePassword.php', { 
                current_password: currentPassword, 
                password: newPassword 
            });
        }
    },
    
    // User profile APIs
    user: {
        async getDetails(userId) {
            try {
                return walletAPI.get(`getUserDetails.php?id=${userId}`);
            } catch (error) {
                console.error('Error in getDetails:', error);
                throw error;
            }
        },
        async update(userId, userData) {
            const formData = new FormData();
            
            // Add each field to formData
            for (const key in userData) {
                if (userData.hasOwnProperty(key)) {
                    formData.append(key, userData[key]);
                }
            }
            
            return walletAPI.post(`addOrUpdateUser.php?id=${userId}`, formData);
        },
        
        async verifyIdentity(documentType, documentFile) {
            const formData = new FormData();
            formData.append('document_type', documentType);
            formData.append('document', documentFile);
            
            return walletAPI.upload('verifyIdentity.php', formData);
        }

    },
    
    // Wallet APIs
    wallet: {
        async getAll() {
            return walletAPI.get('getWallets.php');
        },
        
        async getDetails(walletId) {
            return walletAPI.get(`getWalletDetails.php?wallet_id=${walletId}`);
        },
        
        async create(currencyCode) {
            const formData = new FormData();
            formData.append('currency_code', currencyCode);
            
            return walletAPI.post('addWallet.php', formData);
        },
        
        async delete(walletId) {
            return walletAPI.delete('deleteWallet.php', { wallet_id: walletId });
        },
        
        async transferInternal(sourceWalletId, targetWalletId, amount, description = '') {
            return walletAPI.post('transferFunds.php', {
                source_wallet_id: sourceWalletId,
                target_wallet_id: targetWalletId,
                amount: amount,
                description: description
            });
        },
        
        async transferExternal(sourceWalletId, recipientName, accountNumber, bankName, amount, description = '') {
            return walletAPI.post('externalTransfer.php', {
                source_wallet_id: sourceWalletId,
                recipient_name: recipientName,
                account_number: accountNumber,
                bank_name: bankName,
                amount: amount,
                description: description
            });
        }
    },
    
    // Card APIs
    card: {
        async getAll() {
            return walletAPI.get('getCards.php');
        },
        
        async create(cardData) {
            return walletAPI.post('addCard.php', cardData);
        },
        
        async update(cardId, walletId, updateData) {
            const formData = new FormData();
            formData.append('card_id', cardId);
            formData.append('wallet_id', walletId);
            
            for (const key in updateData) {
                if (updateData.hasOwnProperty(key)) {
                    formData.append(key, updateData[key]);
                }
            }
            
            return walletAPI.post('updateCard.php', formData);
        },
        
        async delete(cardId) {
            return walletAPI.delete('deleteCard.php', { card_id: cardId });
        }
    },
    
    // Bank account APIs
    bankAccount: {
        async getAll() {
            return walletAPI.get('getBankAccount.php');
        },
        
        async create(accountData) {
            return walletAPI.post('addBankAccount.php', accountData);
        },
        
        async delete(bankAccountId) {
            console.log('Deleting bank account with ID:', bankAccountId);
            return walletAPI.delete('deleteBankAccount.php', { bank_account_id: bankAccountId });
        },
        async update(bankAccountId, updateData) {
        return walletAPI.post('updateBankAccount.php', {
            bank_account_id: bankAccountId,
            ...updateData
        });
     }
    },
    
    // Transaction APIs
    transaction: {
        async getRecent(limit = 5) {
            return walletAPI.get(`getTransactions.php${limit ? `?limit=${limit}` : ''}`);
        },
        
        async getByWalletId(walletId) {
            // This endpoint doesn't exist yet, but would be useful
            return walletAPI.get(`getWalletTransactions.php?wallet_id=${walletId}`);
        },
        
        async getByType(type) {
            return walletAPI.get(`getTransactions.php?type=${type}`);
        }
    }
};

// Initialize the API service
walletAPI.init();

document.addEventListener('DOMContentLoaded', () => {
    console.log('Page loaded');
    const userId = sessionStorage.getItem('user_id');
    const currentPage = window.location.pathname.split('/').pop(); // e.g., 'dashboard.html'
    const navbar = document.querySelector('.navbar');

    // Update navbar based on login status
    if (navbar) {
        const navLinksContainer = document.getElementById('navLinks') || document.querySelector('.nav-links');
        if (navLinksContainer) {
            if (userId) {
                navLinksContainer.innerHTML = `
                    <li><a href="dashboard.html"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="profile.html"><i class="fas fa-user"></i> Profile</a></li>
                    <li><a href="#" id="signOut"><i class="fas fa-sign-out-alt"></i> Sign Out</a></li>
                `;
            } else {
                navLinksContainer.innerHTML = `
                    <li><a href="index.html#features"><i class="fas fa-star"></i> Features</a></li>
                    <li><a href="index.html#about"><i class="fas fa-info-circle"></i> About</a></li>
                    <li><a href="index.html#contact"><i class="fas fa-envelope"></i> Contact</a></li>
                    <li><a href="register.html" class="btn primary-btn"><i class="fas fa-user-plus"></i> Sign Up</a></li>
                `;
            }
        }
    }

    // Page-specific initialization
    switch (currentPage) {
        case 'login.html':
            initLogin();
            break;
        case 'dashboard.html':
            initDashboard(userId);
            break;
        case 'profile.html':
            // Profile initialization is handled in profile.html
            break;
        case 'index.html':
            // Landing page logic
            initLandingPage();
            break;
        default:
            console.log('Current page:', currentPage);
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
    
    // Smooth scrolling for navigation links
    initSmoothScrolling();
});

// Smooth scrolling for navigation links
function initSmoothScrolling() {
    const navLinks = document.querySelectorAll('.nav-links a, .sidebar-nav a');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');
            
            // Skip if it's the sign out link or doesn't start with # and isn't an internal page
            if (link.id === 'signOut' || (!href.startsWith('#') && (href.includes('://') || href.startsWith('mailto:')))) {
                return;
            }
            
            if (href.startsWith('#')) {
                e.preventDefault();
                const sectionId = href.substring(1);
                const section = document.getElementById(sectionId);
                if (section) {
                    section.scrollIntoView({ behavior: 'smooth' });
                }
            } else if (href.includes('#')) {
                // Handle links like dashboard.html#wallets
                const pagePart = href.split('#')[0];
                const sectionId = href.split('#')[1];
                
                if (window.location.pathname.endsWith(pagePart)) {
                    e.preventDefault();
                    const section = document.getElementById(sectionId);
                    if (section) {
                        section.scrollIntoView({ behavior: 'smooth' });
                    }
                }
            }
        });
    });
}

// Landing page initialization
function initLandingPage() {
    // Button hover effect
    const buttons = document.querySelectorAll('.btn');
    if (buttons.length > 0) {
        buttons.forEach(btn => {
            btn.addEventListener('mouseover', () => btn.style.transform = 'translateY(-2px)');
            btn.addEventListener('mouseout', () => btn.style.transform = 'translateY(0)');
        });
    }
    
    // Testimonials slider if present
    const testimonialsContainer = document.querySelector('.testimonials-container');
    if (testimonialsContainer) {
        const testimonials = testimonialsContainer.querySelectorAll('.testimonial');
        let currentIndex = 0;
        
        function showTestimonial(index) {
            testimonials.forEach((testimonial, i) => {
                testimonial.style.display = i === index ? 'block' : 'none';
            });
        }
        
        document.getElementById('prevTestimonial')?.addEventListener('click', () => {
            currentIndex = (currentIndex - 1 + testimonials.length) % testimonials.length;
            showTestimonial(currentIndex);
        });
        
        document.getElementById('nextTestimonial')?.addEventListener('click', () => {
            currentIndex = (currentIndex + 1) % testimonials.length;
            showTestimonial(currentIndex);
        });
        
        // Show the first testimonial initially
        showTestimonial(currentIndex);
        
        // Auto-rotate testimonials
        setInterval(() => {
            currentIndex = (currentIndex + 1) % testimonials.length;
            showTestimonial(currentIndex);
        }, 5000);
    }
}

function initLogin() {
    const loginForm = document.getElementById('loginForm');
    const showPasswordCheckbox = document.getElementById('showPassword');
    const passwordField = document.getElementById('userPassword');

    if (showPasswordCheckbox && passwordField) {
        showPasswordCheckbox.addEventListener('change', () => {
            passwordField.type = showPasswordCheckbox.checked ? 'text' : 'password';
        });
    }

    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = document.getElementById('userEmail').value.trim();
            const password = document.getElementById('userPassword').value.trim();
            const resultElement = document.getElementById('loginResult');

            if (!email || !password) {
                showResult('Please enter both email and password', 'error', resultElement);
                return;
            }

            // Show loading state
            showResult('Logging in...', 'info', resultElement);
            
            try {
                const response = await walletAPI.auth.login(email, password);
                
                if (response.success) {
                    sessionStorage.setItem('user_id', response.user_id);
                    showResult('Login successful! Redirecting...', 'success', resultElement);
                    setTimeout(() => window.location.href = 'dashboard.html', 1000);
                } else {
                    showResult(response.message || 'Login failed. Please check your credentials.', 'error', resultElement);
                }
            } catch (error) {
                console.error('Login error:', error);
                showResult(error.response?.data?.error || 'An error occurred. Please try again.', 'error', resultElement);
            }
        });
    }
}


// Dashboard Initialization
function initDashboard(userId) {
    if (!userId) {
        window.location.href = 'login.html';
        return;
    }

    // Fetch user details
    fetchUserDetails();
    
    // Initialize dashboard sections
    fetchWallets();
    fetchCards();
    fetchBankAccounts();
    fetchTransactions();
    
    // Transaction type filter
    const transactionTypeFilter = document.getElementById('transactionTypeFilter');
    if (transactionTypeFilter) {
        transactionTypeFilter.addEventListener('change', () => {
            fetchTransactions(transactionTypeFilter.value);
        });
    }
}

// Fetch user details using the API service
function fetchUserDetails() {
    const userId = sessionStorage.getItem('user_id');
    if (!userId) {
        console.error('No user ID found in session storage');
        return;
    }
    
    // Use the walletAPI service
    walletAPI.user.getDetails(userId)
        .then(response => {
            if (response && response.success) {
                const user = response.data;
                
                // Update user email in sidebar and header
                const userEmailElements = document.querySelectorAll('#userEmail');
                userEmailElements.forEach(el => {
                    el.textContent = user.email;
                });
                
                // Update user ID if present
                const userIdElement = document.getElementById('userId');
                if (userIdElement) {
                    userIdElement.textContent = user.user_id;
                }
                
                // Update profile name if on profile page
                const profileNameElement = document.getElementById('profileName');
                if (profileNameElement) {
                    profileNameElement.textContent = `${user.first_name} ${user.last_name}`;
                }
                
                // Update form fields on profile page
                const firstNameInput = document.getElementById('firstName');
                const lastNameInput = document.getElementById('lastName');
                const emailInput = document.getElementById('email');
                const phoneInput = document.getElementById('phoneNumber');
                const dobInput = document.getElementById('dateOfBirth');
                
                if (firstNameInput) firstNameInput.value = user.first_name || '';
                if (lastNameInput) lastNameInput.value = user.last_name || '';
                if (emailInput) emailInput.value = user.email || '';
                if (phoneInput) phoneInput.value = user.phone_number || '';
                if (dobInput) dobInput.value = user.date_of_birth || '';
            } else {
                console.error('Failed to fetch user details:', response ? response.message : 'No response');
                // Optionally redirect to login if unauthorized
                if (response && response.message === 'Unauthorized') {
                    sessionStorage.removeItem('user_id');
                    window.location.href = 'login.html';
                }
            }
        })
        .catch(error => {
            console.error('Error fetching user details:', error);
            // Only redirect if it's an auth error
            if (error.response && error.response.status === 401) {
                sessionStorage.removeItem('user_id');
                window.location.href = 'login.html';
            }
        });
}

// Fetch wallets using the API service
function fetchWallets() {
    const walletSummary = document.getElementById('walletSummary');
    
    if (!walletSummary) return;
    
    walletSummary.innerHTML = '<div class="loading-spinner"><i class="fas fa-spinner fa-spin"></i> Loading wallets...</div>';
    
    walletAPI.wallet.getAll()
        .then(response => {
            if (response.success) {
                const wallets = response.data;
                
                // Update wallet count in stats
                const walletCountElement = document.getElementById('walletCount');
                if (walletCountElement) walletCountElement.textContent = wallets.length;
                
                if (wallets.length === 0) {
                    walletSummary.innerHTML = `
                        <div class="empty-state">
                            <i class="fas fa-wallet fa-3x"></i>
                            <p>You don't have any wallets yet</p>
                            <button class="btn primary-btn" onclick="addWallet()">
                                <i class="fas fa-plus"></i> Add Your First Wallet
                            </button>
                        </div>
                    `;
                    return;
                }
                
                walletSummary.innerHTML = '';
                
                wallets.forEach(wallet => {
                    const walletCard = document.createElement('div');
                    walletCard.className = 'wallet-card';
                    walletCard.innerHTML = `
                        <h3>Wallet #${wallet.wallet_id}</h3>
                        <div class="wallet-balance">${formatCurrency(wallet.balance, wallet.currency_code)}</div>
                        <span class="wallet-currency">${wallet.currency_code}</span>
                        <span class="wallet-status status-${wallet.wallet_status.toLowerCase()}">${formatStatus(wallet.wallet_status)}</span>
                        <div class="wallet-actions">
                            <button class="btn primary-btn" onclick="initiateTransaction(${wallet.wallet_id})">
                                <i class="fas fa-exchange-alt"></i> Transfer
                            </button>
                            <button class="btn secondary-btn" onclick="viewWalletDetails(${wallet.wallet_id})">
                                <i class="fas fa-eye"></i> Details
                            </button>
                            <button class="btn danger-btn" onclick="deleteWallet(${wallet.wallet_id})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    `;
                    walletSummary.appendChild(walletCard);
                });
            } else {
                walletSummary.innerHTML = `<p class="error-message">${response.message}</p>`;
            }
        })
        .catch(error => {
            console.error('Error fetching wallets:', error);
            walletSummary.innerHTML = `<p class="error-message">Failed to load wallets. Please try again.</p>`;
        });
}


// Fetch Cards
function fetchCards() {
    const cardList = document.getElementById('card-list');
    
    if (!cardList) return;
    
    cardList.innerHTML = '<div class="loading-spinner"><i class="fas fa-spinner fa-spin"></i> Loading cards...</div>';
    
    axios.get('http://localhost/Wallet/Wallet - Server/user/v1/getCards.php', { withCredentials: true })
        .then(res => {
            if (res.data.success) {
                const cards = res.data.data;
                
                // Update card count in stats
                const cardCountElement = document.getElementById('cardCount');
                if (cardCountElement) cardCountElement.textContent = cards.length;
                
                if (cards.length === 0) {
                    cardList.innerHTML = `
                        <div class="empty-state">
                            <i class="fas fa-credit-card fa-3x"></i>
                            <p>You don't have any cards yet</p>
                            <button class="btn primary-btn" onclick="addCard()">
                                <i class="fas fa-plus"></i> Add Your First Card
                            </button>
                        </div>
                    `;
                    return;
                }
                
                cardList.innerHTML = '';
                
                cards.forEach(card => {
                    const cardItem = document.createElement('div');
                    cardItem.className = 'card-item';
                    cardItem.style.background = getCardBackground(card.card_type);
                    
                    cardItem.innerHTML = `
                        <div class="card-type">${getCardTypeIcon(card.card_type)}</div>
                        <h3>${card.card_nickname || 'My Card'}</h3>
                        <div class="card-number">**** **** **** ${card.card_number_last_four}</div>
                        <div class="card-details">
                            <div class="card-holder">
                                <span>CARD HOLDER</span>
                                ${card.cardholder_name}
                            </div>
                            <div class="card-expiry">
                                <span>EXPIRES</span>
                                ${String(card.expiry_month).padStart(2, '0')}/${card.expiry_year}
                            </div>
                        </div>
                        <div class="card-actions">
                            <button class="card-action-btn" onclick="deleteCard(${card.card_id})">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    `;
                    
                    cardList.appendChild(cardItem);
                });
            } else {
                cardList.innerHTML = `<p class="error-message">${res.data.message}</p>`;
            }
        })
        .catch(error => {
            console.error('Error fetching cards:', error);
            cardList.innerHTML = `<p class="error-message">Failed to load cards. Please try again.</p>`;
        });
}

// Fetch Bank Accounts
function fetchBankAccounts() {
    const bankAccountList = document.getElementById('bank-account-list');
    
    if (!bankAccountList) return;
    
    bankAccountList.innerHTML = '<div class="loading-spinner"><i class="fas fa-spinner fa-spin"></i> Loading bank accounts...</div>';
    
    axios.get('http://localhost/Wallet/Wallet - Server/user/v1/getBankAccount.php', { withCredentials: true })
        .then(res => {
            if (res.data.success) {
                const bankAccounts = res.data.data;
                
                // Update bank account count in stats
                const bankCountElement = document.getElementById('bankCount');
                if (bankCountElement) bankCountElement.textContent = bankAccounts.length;
                
                if (bankAccounts.length === 0) {
                    bankAccountList.innerHTML = `
                        <div class="empty-state">
                            <i class="fas fa-university fa-3x"></i>
                            <p>You don't have any bank accounts yet</p>
                            <button class="btn primary-btn" onclick="addBankAccount()">
                                <i class="fas fa-plus"></i> Add Your First Bank Account
                            </button>
                        </div>
                    `;
                    return;
                }
                
                bankAccountList.innerHTML = '';
                
                bankAccounts.forEach(account => {
                    const accountItem = document.createElement('div');
                    accountItem.className = 'bank-account-item';
                    
                    accountItem.innerHTML = `
                        <h3 class="bank-name">${account.bank_name}</h3>
                        <p>${account.account_holder_name}</p>
                        <p class="account-number">${maskAccountNumber(account.account_number)}</p>
                        <span class="account-type">${formatAccountType(account.account_type)}</span>
                        <div class="account-actions">
                            <button class="btn secondary-btn" onclick="editBankAccount(${account.bank_account_id})">
                                <i class="fas fa-pencil-alt"></i>
                            </button>
                            <button class="btn danger-btn" onclick="deleteBankAccount(${account.bank_account_id})">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    `;
                    
                    bankAccountList.appendChild(accountItem);
                });
            } else {
                bankAccountList.innerHTML = `<p class="error-message">${res.data.message}</p>`;
            }
        })
        .catch(error => {
            console.error('Error fetching bank accounts:', error);
            bankAccountList.innerHTML = `<p class="error-message">Failed to load bank accounts. Please try again.</p>`;
        });
}

// Fetch Transactions
function fetchTransactions(type = 'ALL') {
    const transactionsList = document.getElementById('recentTransactions');
    
    if (!transactionsList) return;
    
    transactionsList.innerHTML = `
        <tr>
            <td colspan="5" class="loading-cell">
                <div class="loading-spinner">
                    <i class="fas fa-spinner fa-spin"></i> Loading transactions...
                </div>
            </td>
        </tr>
    `;
    
    let url = 'http://localhost/Wallet/Wallet - Server/user/v1/getTransactions.php';
    if (type !== 'ALL') {
        url += `?type=${type}`;
    }
    
    axios.get(url, { withCredentials: true })
        .then(res => {
            if (res.data.success) {
                const transactions = res.data.data;
                
                // Update transaction count in stats
                const transactionCountElement = document.getElementById('transactionCount');
                if (transactionCountElement) transactionCountElement.textContent = transactions.length;
                
                if (transactions.length === 0) {
                    transactionsList.innerHTML = `
                        <tr>
                            <td colspan="5" class="empty-cell">
                                <div class="empty-state">
                                    <i class="fas fa-exchange-alt fa-3x"></i>
                                    <p>No transactions found</p>
                                </div>
                            </td>
                        </tr>
                    `;
                    return;
                }
                
                transactionsList.innerHTML = '';
                
                transactions.forEach(transaction => {
                    const row = document.createElement('tr');
                    
                    const typeClass = getTransactionTypeClass(transaction.transaction_type);
                    const amountClass = transaction.transaction_type.includes('WITHDRAWAL') || 
                                       transaction.transaction_type === 'TRANSFER_SENT' || 
                                       transaction.transaction_type === 'PAYMENT' 
                                       ? 'amount-negative' : 'amount-positive';
                    
                    // Format the transaction date
                    const date = new Date(transaction.timestamp || Date.now());
                    const formattedDate = `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`;
                    
                    row.innerHTML = `
                        <td>
                            <span class="transaction-type ${typeClass}">
                                ${formatTransactionType(transaction.transaction_type)}
                            </span>
                        </td>
                        <td class="transaction-amount ${amountClass}">
                            ${transaction.transaction_type.includes('WITHDRAWAL') || 
                              transaction.transaction_type === 'TRANSFER_SENT' || 
                              transaction.transaction_type === 'PAYMENT' 
                              ? '-' : '+'} ${formatCurrency(transaction.amount, transaction.currency_code)}
                        </td>
                        <td>${transaction.currency_code}</td>
                        <td>
                            <span class="transaction-status status-${transaction.status.toLowerCase()}">
                                ${formatStatus(transaction.status)}
                            </span>
                        </td>
                        <td class="transaction-date">${formattedDate}</td>
                    `;
                    
                    transactionsList.appendChild(row);
                });
            } else {
                transactionsList.innerHTML = `
                    <tr>
                        <td colspan="5" class="error-cell">
                            <p class="error-message">${res.data.message}</p>
                        </td>
                    </tr>
                `;
            }
        })
        .catch(error => {
            console.error('Error fetching transactions:', error);
            transactionsList.innerHTML = `
                <tr>
                    <td colspan="5" class="error-cell">
                        <p class="error-message">Failed to load transactions. Please try again.</p>
                    </td>
                </tr>
            `;
        });
}

// Add Wallet Function
function addWallet() {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-wallet"></i> Add New Wallet</h2>
                <button class="close-btn" onclick="this.parentElement.parentElement.parentElement.remove()">&times;</button>
            </div>
            <form id="addWalletForm" class="modal-form">
                <div class="input-group">
                    <label for="walletCurrency">Currency:</label>
                    <select id="walletCurrency" class="input-field" required>
                        <option value="">Select a currency</option>
                        <option value="USD">USD - United States Dollar</option>
                        <option value="EUR">EUR - Euro</option>
                        <option value="GBP">GBP - British Pound</option>
                        <option value="JPY">JPY - Japanese Yen</option>
                        <option value="CAD">CAD - Canadian Dollar</option>
                        <option value="AUD">AUD - Australian Dollar</option>
                        <option value="CHF">CHF - Swiss Franc</option>
                    </select>
                </div>
                
                <div class="checkbox-group">
                    <input type="checkbox" id="attachCard" onchange="toggleCardFields()">
                    <label for="attachCard">Attach a card to this wallet</label>
                </div>
                
                <div id="cardFields" style="display: none;">
                    <h3>Card Information</h3>
                    
                    <div class="input-group">
                        <label for="cardNickname">Card Nickname (Optional):</label>
                        <input type="text" id="cardNickname" class="input-field" placeholder="e.g., My Visa Card">
                    </div>
                    
                    <div class="input-group">
                        <label for="cardholderName">Cardholder Name:</label>
                        <input type="text" id="cardholderName" class="input-field" placeholder="Name as it appears on card">
                    </div>
                    
                    <div class="input-group">
                        <label for="cardNumberLastFour">Last Four Digits:</label>
                        <input type="text" id="cardNumberLastFour" class="input-field" pattern="[0-9]{4}" maxlength="4" placeholder="1234">
                    </div>
                    
                    <div class="input-group">
                        <label for="cardType">Card Type:</label>
                        <select id="cardType" class="input-field">
                            <option value="">Select card type</option>
                            <option value="VISA">Visa</option>
                            <option value="MASTERCARD">Mastercard</option>
                            <option value="AMEX">American Express</option>
                            <option value="DISCOVER">Discover</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-row">
                        <div class="input-group">
                            <label for="expiryMonth">Expiry Month:</label>
                            <select id="expiryMonth" class="input-field">
                                <option value="">MM</option>
                                ${Array.from({length: 12}, (_, i) => `<option value="${i+1}">${String(i+1).padStart(2, '0')}</option>`).join('')}
                            </select>
                        </div>
                        <div class="input-group">
                            <label for="expiryYear">Expiry Year:</label>
                            <select id="expiryYear" class="input-field">
                                <option value="">YYYY</option>
                                ${Array.from({length: 10}, (_, i) => {
                                    const year = new Date().getFullYear() + i;
                                    return `<option value="${year}">${year}</option>`;
                                }).join('')}
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="modal-actions">
                    <button type="submit" class="btn primary-btn">
                        <i class="fas fa-plus"></i> Add Wallet
                    </button>
                    <button type="button" class="btn secondary-btn" onclick="this.parentElement.parentElement.parentElement.parentElement.remove()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                </div>
            </form>
        </div>
    `;
    document.body.appendChild(modal);

    // Close modal when clicking outside
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.remove();
        }
    });

    // Function to toggle card fields display
    window.toggleCardFields = function() {
        const cardFields = document.getElementById('cardFields');
        const attachCard = document.getElementById('attachCard');
        
        if (attachCard.checked) {
            cardFields.style.display = 'block';
        } else {
            cardFields.style.display = 'none';
        }
    };

    const form = document.getElementById('addWalletForm');
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const currency = document.getElementById('walletCurrency').value;
        const attachCard = document.getElementById('attachCard').checked;

        if (!currency) {
            showToast('Please select a currency', 'error');
            return;
        }

        // Validate card fields if attach card is checked
        if (attachCard) {
            const cardholderName = document.getElementById('cardholderName').value.trim();
            const cardNumberLastFour = document.getElementById('cardNumberLastFour').value.trim();
            const cardType = document.getElementById('cardType').value;
            const expiryMonth = document.getElementById('expiryMonth').value;
            const expiryYear = document.getElementById('expiryYear').value;
            
            if (!cardholderName || !cardNumberLastFour || !cardType || !expiryMonth || !expiryYear) {
                showToast('Please fill in all required card fields', 'error');
                return;
            }
            
            if (!/^\d{4}$/.test(cardNumberLastFour)) {
                showToast('Card number must be 4 digits', 'error');
                return;
            }
        }

        try {
            // Show loading state
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            submitBtn.disabled = true;
            
            console.log('Sending currency:', currency);
            const response = await axios.post(
                'http://localhost/Wallet/Wallet - Server/user/v1/addWallet.php', 
                { currency_code: currency }, 
                { 
                    headers: { 'Content-Type': 'application/json' }, 
                    withCredentials: true 
                }
            );
            console.log('Response:', response.data);
            
            if (response.data.success) {
                showToast('Wallet added successfully', 'success');
                fetchWallets();
                modal.remove();
            } else {
                showToast(response.data.message || 'Failed to add wallet', 'error');
                // Reset button
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
            }
        } catch (error) {
            console.error('Error adding wallet:', error);
            showToast(error.response?.data?.message || 'An error occurred. Please try again.', 'error');
            
            // Reset button
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.innerHTML = '<i class="fas fa-plus"></i> Add Wallet';
            submitBtn.disabled = false;
        }
    });
}

// Add Card Function - Enhanced version
function addCard() {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-credit-card"></i> Add New Card</h2>
                <button class="close-btn" onclick="this.parentElement.parentElement.parentElement.remove()">&times;</button>
            </div>
            <form id="addCardForm" class="modal-form">
                <div class="input-group">
                    <label for="walletId">Select Wallet:</label>
                    <select id="walletId" class="input-field" required>
                        <option value="">Select a wallet</option>
                        <!-- Wallet options will be loaded dynamically -->
                    </select>
                </div>
                <div class="input-group">
                    <label for="cardNickname">Card Nickname (Optional):</label>
                    <input type="text" id="cardNickname" class="input-field" placeholder="e.g., My Visa Card">
                </div>
                <div class="input-group">
                    <label for="cardholderName">Cardholder Name:</label>
                    <input type="text" id="cardholderName" class="input-field" required placeholder="Name as it appears on card">
                </div>
                <div class="input-group">
                    <label for="cardNumberLastFour">Last Four Digits:</label>
                    <input type="text" id="cardNumberLastFour" class="input-field" required pattern="[0-9]{4}" maxlength="4" placeholder="1234">
                </div>
                <div class="input-group">
                    <label for="cardType">Card Type:</label>
                    <select id="cardType" class="input-field" required>
                        <option value="">Select card type</option>
                        <option value="VISA">Visa</option>
                        <option value="MASTERCARD">Mastercard</option>
                        <option value="AMEX">American Express</option>
                        <option value="DISCOVER">Discover</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>
                <div class="form-row">
                    <div class="input-group">
                        <label for="expiryMonth">Expiry Month:</label>
                        <select id="expiryMonth" class="input-field" required>
                            <option value="">MM</option>
                            ${Array.from({length: 12}, (_, i) => `<option value="${i+1}">${String(i+1).padStart(2, '0')}</option>`).join('')}
                        </select>
                    </div>
                    <div class="input-group">
                        <label for="expiryYear">Expiry Year:</label>
                        <select id="expiryYear" class="input-field" required>
                            <option value="">YYYY</option>
                            ${Array.from({length: 10}, (_, i) => {
                                const year = new Date().getFullYear() + i;
                                return `<option value="${year}">${year}</option>`;
                            }).join('')}
                        </select>
                    </div>
                </div>
                <div class="input-group">
                    <label for="cardCurrency">Currency:</label>
                    <select id="cardCurrency" class="input-field" required>
                        <option value="">Select a currency</option>
                        <option value="USD">USD - United States Dollar</option>
                        <option value="EUR">EUR - Euro</option>
                        <option value="GBP">GBP - British Pound</option>
                        <option value="JPY">JPY - Japanese Yen</option>
                        <option value="CAD">CAD - Canadian Dollar</option>
                    </select>
                </div>
                <div class="checkbox-group">
                    <input type="checkbox" id="isPrimary">
                    <label for="isPrimary">Set as primary card</label>
                </div>
                <div class="modal-actions">
                    <button type="submit" class="btn primary-btn">
                        <i class="fas fa-plus"></i> Add Card
                    </button>
                    <button type="button" class="btn secondary-btn" onclick="this.parentElement.parentElement.parentElement.parentElement.remove()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                </div>
            </form>
        </div>
    `;
    document.body.appendChild(modal);
    
    // Close modal when clicking outside
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.remove();
        }
    });

    // Load wallets for the select dropdown
    axios.get('http://localhost/Wallet/Wallet - Server/user/v1/getWallets.php', { withCredentials: true })
        .then(res => {
            if (res.data.success) {
                const walletSelect = document.getElementById('walletId');
                res.data.data.forEach(wallet => {
                    const option = document.createElement('option');
                    option.value = wallet.wallet_id;
                    option.textContent = `Wallet #${wallet.wallet_id} (${wallet.currency_code})`;
                    walletSelect.appendChild(option);
                });
            }
        })
        .catch(error => console.error('Error loading wallets:', error));

    // Form submission
    const form = document.getElementById('addCardForm');
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const walletId = document.getElementById('walletId').value;
        const nickname = document.getElementById('cardNickname').value.trim();
        const cardholderName = document.getElementById('cardholderName').value.trim();
        const lastFour = document.getElementById('cardNumberLastFour').value.trim();
        const cardType = document.getElementById('cardType').value;
        const expiryMonth = document.getElementById('expiryMonth').value;
        const expiryYear = document.getElementById('expiryYear').value;
        const currency = document.getElementById('cardCurrency').value;
        const isPrimary = document.getElementById('isPrimary').checked;

        if (!walletId || !cardholderName || !lastFour || !cardType || !expiryMonth || !expiryYear || !currency) {
            showToast('Please fill in all required fields', 'error');
            return;
        }

        if (!/^\d{4}$/.test(lastFour)) {
            showToast('Card number should be 4 digits', 'error');
            return;
        }

        try {
            // Show spinner in the submit button
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
            submitBtn.disabled = true;
            
            const res = await axios.post('http://localhost/Wallet/Wallet - Server/user/v1/addCard.php', {
                wallet_id: parseInt(walletId),
                card_nickname: nickname || null,
                cardholder_name: cardholderName,
                card_number_last_four: lastFour,
                card_type: cardType,
                expiry_month: parseInt(expiryMonth),
                expiry_year: parseInt(expiryYear),
                currency_code: currency,
                is_primary: isPrimary
            }, {
                headers: { 'Content-Type': 'application/json' },
                withCredentials: true
            });
            
            if (res.data.success) {
                showToast('Card added successfully', 'success');
                fetchCards();
                modal.remove();
            } else {
                showToast(res.data.message || 'Failed to add card', 'error');
                // Reset button
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
            }
        } catch (error) {
            console.error('Error adding card:', error);
            showToast(error.response?.data?.error || 'An error occurred. Please try again.', 'error');
            // Reset button
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.innerHTML = '<i class="fas fa-plus"></i> Add Card';
            submitBtn.disabled = false;
        }
    });
}
    
// Add Bank Account Function - Enhanced version
function addBankAccount() {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">  
                <h2><i class="fas fa-university"></i> Add Bank Account</h2>
                <button class="close-btn" onclick="this.parentElement.parentElement.parentElement.remove()">&times;</button>
            </div>
            <form id="addBankAccountForm" class="modal-form">
                <div class="input-group">
                    <label for="accountNickname">Account Nickname (Optional):</label>
                    <input type="text" id="accountNickname" class="input-field" placeholder="e.g., My Checking Account">
                </div>
                <div class="input-group">
                    <label for="accountHolder">Account Holder Name:*</label>
                    <input type="text" id="accountHolder" class="input-field" required placeholder="Full name on account">
                </div>
                <div class="input-group">
                    <label for="bankName">Bank Name:*</label>
                    <input type="text" id="bankName" class="input-field" required placeholder="Name of your bank">
                </div>
                <div class="input-group">
                    <label for="accountNumber">Account Number:* (10-12 digits)</label>
                    <input type="text" id="accountNumber" class="input-field" required pattern="\\d{10,12}" 
                           title="Account number must be 10-12 digits" placeholder="Account number">
                </div>
                <div class="input-group">
                    <label for="routingNumber">Routing Number:* (9 digits)</label>
                    <input type="text" id="routingNumber" class="input-field" required pattern="\\d{9}" 
                           title="Routing number must be 9 digits" placeholder="Routing number">
                </div>
                <div class="input-group">
                    <label for="accountType">Account Type:*</label>
                    <select id="accountType" class="input-field" required>
                        <option value="">Select account type</option>
                        <option value="CHECKING">Checking</option>
                        <option value="SAVINGS">Savings</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>
                <div class="input-group">
                    <label for="bankCurrency">Currency:*</label>
                    <select id="bankCurrency" class="input-field" required>
                        <option value="">Select a currency</option>
                        <option value="USD">USD - United States Dollar</option>
                        <option value="EUR">EUR - Euro</option>
                        <option value="GBP">GBP - British Pound</option>
                        <option value="JPY">JPY - Japanese Yen</option>
                        <option value="CAD">CAD - Canadian Dollar</option>
                    </select>
                </div>
                <div class="checkbox-group">
                    <input type="checkbox" id="isPrimaryAccount">
                    <label for="isPrimaryAccount">Set as primary account</label>
                </div>
                <div class="modal-actions">
                    <button type="submit" class="btn primary-btn">
                        <i class="fas fa-plus"></i> Add Bank Account
                    </button>
                    <button type="button" class="btn secondary-btn" onclick="this.parentElement.parentElement.parentElement.parentElement.remove()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                </div>
            </form>
        </div>
    `;
    document.body.appendChild(modal);

    // Close modal when clicking outside
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.remove();
        }
    });

    const form = document.getElementById('addBankAccountForm');
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const nickname = document.getElementById('accountNickname').value.trim();
        const holder = document.getElementById('accountHolder').value.trim();
        const bank = document.getElementById('bankName').value.trim();
        const accountNum = document.getElementById('accountNumber').value.trim();
        const routing = document.getElementById('routingNumber').value.trim();
        const type = document.getElementById('accountType').value;
        const currency = document.getElementById('bankCurrency').value;
        const isPrimary = document.getElementById('isPrimaryAccount').checked;

        if (!holder || !bank || !accountNum || !routing || !type || !currency) {
            showToast('All fields marked with * are required', 'error');
            return;
        }
        
        if (!/^\d{10,12}$/.test(accountNum)) {
            showToast('Account number must be 10-12 digits', 'error');
            return;
        }
        
        if (!/^\d{9}$/.test(routing)) {
            showToast('Routing number must be 9 digits', 'error');
            return;
        }

        try {
            // Show spinner in the submit button
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
            submitBtn.disabled = true;
            
            const res = await axios.post('http://localhost/Wallet/Wallet - Server/user/v1/addBankAccount.php', {
                account_nickname: nickname || null,
                account_holder_name: holder,
                bank_name: bank,
                account_number: accountNum,
                routing_number: routing,
                account_type: type,
                currency_code: currency,
                is_primary: isPrimary,
                is_verified: false
            }, {
                headers: { 'Content-Type': 'application/json' },
                withCredentials: true
            });
            
            if (res.data.success) {
                showToast('Bank account added successfully', 'success');
                fetchBankAccounts();
                modal.remove();
            } else {
                showToast(res.data.message || 'Failed to add bank account', 'error');
                // Reset button
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
            }
        } catch (error) {
            console.error('Error adding bank account:', error);
            showToast(error.response?.data?.error || 'An error occurred. Please try again.', 'error');
            // Reset button
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.innerHTML = '<i class="fas fa-plus"></i> Add Bank Account';
            submitBtn.disabled = false;
        }
    });
}
function editBankAccount(bankAccountId) {
    // Show loading toast
    showToast('Loading account details...', 'info');
    
    // Fetch all bank accounts and find the specific one
    walletAPI.bankAccount.getAll()
        .then(response => {
            if (!response.success) {
                showToast('Error loading bank accounts', 'error');
                return;
            }
            
            // Find the specific account by ID
            const accountData = response.data.find(account => account.bank_account_id == bankAccountId);
            
            if (!accountData) {
                showToast('Bank account not found', 'error');
                return;
            }
            
            // Create the modal with pre-filled data
            const modal = document.createElement('div');
            modal.className = 'modal';
            modal.innerHTML = `
                <div class="modal-content">
                    <div class="modal-header">
                        <h2><i class="fas fa-university"></i> Edit Bank Account</h2>
                        <button class="close-btn" onclick="this.parentElement.parentElement.parentElement.remove()">&times;</button>
                    </div>
                    <form id="editBankAccountForm" class="modal-form">
                        <input type="hidden" id="editBankAccountId" value="${bankAccountId}">
                        
                        <div class="input-group">
                            <label for="accountNickname">Account Nickname (Optional):</label>
                            <input type="text" id="accountNickname" class="input-field" placeholder="e.g., My Checking Account" value="${accountData.account_nickname || ''}">
                        </div>
                        
                        <div class="input-group">
                            <label for="accountHolder">Account Holder Name:</label>
                            <input type="text" id="accountHolder" class="input-field" required placeholder="Full name on account" value="${accountData.account_holder_name}">
                        </div>
                        
                        <div class="input-group">
                            <label for="bankName">Bank Name:</label>
                            <input type="text" id="bankName" class="input-field" required placeholder="Name of your bank" value="${accountData.bank_name}">
                        </div>
                        
                        <div class="input-group">
                            <label for="accountType">Account Type:</label>
                            <select id="accountType" class="input-field" required>
                                <option value="">Select account type</option>
                                <option value="CHECKING" ${accountData.account_type === 'CHECKING' ? 'selected' : ''}>Checking</option>
                                <option value="SAVINGS" ${accountData.account_type === 'SAVINGS' ? 'selected' : ''}>Savings</option>
                                <option value="OTHER" ${accountData.account_type === 'OTHER' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                        
                        <div class="checkbox-group">
                            <input type="checkbox" id="isPrimaryAccount" ${accountData.is_primary == 1 ? 'checked' : ''}>
                            <label for="isPrimaryAccount">Set as primary account</label>
                        </div>
                        
                        <div class="modal-actions">
                            <button type="submit" class="btn primary-btn">
                                <i class="fas fa-save"></i> Save Changes
                            </button>
                            <button type="button" class="btn secondary-btn" onclick="this.parentElement.parentElement.parentElement.parentElement.remove()">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                    </form>
                </div>
            `;
            document.body.appendChild(modal);

            // Close modal when clicking outside
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.remove();
                }
            });

            // Form submission
            const form = document.getElementById('editBankAccountForm');
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                
                const bankAccountId = document.getElementById('editBankAccountId').value;
                const accountNickname = document.getElementById('accountNickname').value.trim();
                const accountHolder = document.getElementById('accountHolder').value.trim();
                const bankName = document.getElementById('bankName').value.trim();
                const accountType = document.getElementById('accountType').value;
                const isPrimary = document.getElementById('isPrimaryAccount').checked;
                
                if (!accountHolder || !bankName || !accountType) {
                    showToast('Please fill in all required fields', 'error');
                    return;
                }
                
                try {
                    // Show loading state
                    const submitBtn = form.querySelector('button[type="submit"]');
                    const originalBtnText = submitBtn.innerHTML;
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
                    submitBtn.disabled = true;
                    
                    const updateData = {
                        account_nickname: accountNickname || null,
                        account_holder_name: accountHolder,
                        bank_name: bankName,
                        account_type: accountType,
                        is_primary: isPrimary
                    };
                    
                    const response = await walletAPI.bankAccount.update(bankAccountId, updateData);
                    
                    if (response.success) {
                        showToast('Bank account updated successfully', 'success');
                        fetchBankAccounts(); // Refresh the bank account list
                        modal.remove(); // Close the modal
                    } else {
                        showToast(response.message || 'Failed to update bank account', 'error');
                        // Reset button state
                        submitBtn.innerHTML = originalBtnText;
                        submitBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error updating bank account:', error);
                    showToast(error.message || 'An error occurred. Please try again.', 'error');
                    
                    // Reset button state
                    const submitBtn = form.querySelector('button[type="submit"]');
                    submitBtn.innerHTML = '<i class="fas fa-save"></i> Save Changes';
                    submitBtn.disabled = false;
                }
            });
        })
        .catch(error => {
            console.error('Error fetching bank accounts:', error);
            showToast('Could not load bank accounts', 'error');
        });
}
// Delete Card Function
function deleteCard(cardId) {
    if (confirm('Are you sure you want to delete this card?')) {
        axios.delete('http://localhost/Wallet/Wallet - Server/user/v1/deleteCard.php', {
            data: { card_id: cardId },
            withCredentials: true
        })
            .then(res => {
                if (res.data.success) {
                    showToast('Card deleted successfully', 'success');
                    fetchCards();
                } else {
                    showToast(res.data.message || 'Failed to delete card', 'error');
                }
            })
            .catch(error => {
                console.error('Error deleting card:', error);
                showToast(error.response?.data?.error || 'An error occurred. Please try again.', 'error');
            });
    }
}

// Delete Wallet Function
function deleteWallet(walletId) {
    if (confirm('Are you sure you want to delete this wallet?')) {
        walletAPI.wallet.delete(walletId)
            .then(response => {
                if (response.success) {
                    showToast('Wallet deleted successfully', 'success');
                    fetchWallets();
                } else {
                    showToast(response.message || 'Failed to delete wallet', 'error');
                }
            })
            .catch(error => {
                console.error('Error deleting wallet:', error);
                showToast(error.message || 'An error occurred. Please try again.', 'error');
            });
    }
}

// Delete Bank Account Function using walletAPI
function deleteBankAccount(bankAccountId) {
    if (confirm('Are you sure you want to delete this bank account?')) {
        walletAPI.bankAccount.delete(bankAccountId)
            .then(response => {
                if (response.success) {
                    showToast('Bank account deleted successfully', 'success');
                    fetchBankAccounts();
                } else {
                    showToast(response.message || 'Failed to delete bank account', 'error');
                }
            })
            .catch(error => {
                console.error('Error deleting bank account:', error);
                showToast(error.message || 'An error occurred. Please try again.', 'error');
            });
    }
}

// View Wallet Details
function viewWalletDetails(walletId) {
    // Redirect to wallet details page with wallet ID as parameter
    window.location.href = `wallet-details.html?id=${walletId}`;
}

// Update Profile Function
function updateProfile(e) {
    e.preventDefault();
    
    const firstName = document.getElementById('firstName').value.trim();
    const lastName = document.getElementById('lastName').value.trim();
    const email = document.getElementById('email').value.trim();
    const phoneNumber = document.getElementById('phoneNumber').value.trim();
    const dateOfBirth = document.getElementById('dateOfBirth').value;
    
    if (!firstName || !lastName || !email || !dateOfBirth) {
        showToast('Please fill in all required fields', 'error');
        return;
    }
    
    const userId = sessionStorage.getItem('user_id');
    const userData = {
        first_name: firstName,
        last_name: lastName,
        email: email,
        phone_number: phoneNumber,
        date_of_birth: dateOfBirth
    };
    
    // Show loading state
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalBtnText = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    submitBtn.disabled = true;
    
    walletAPI.user.update(userId, userData)
        .then(response => {
            if (response.success) {
                showToast('Profile updated successfully', 'success');
                // Update display name
                const profileNameElement = document.getElementById('profileName');
                if (profileNameElement) {
                    profileNameElement.textContent = `${firstName} ${lastName}`;
                }
                
                // Update email displays
                const userEmailElements = document.querySelectorAll('#userEmail');
                userEmailElements.forEach(el => {
                    el.textContent = email;
                });
            } else {
                showToast(response.message || 'Failed to update profile', 'error');
            }
            
            // Reset button
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        })
        .catch(error => {
            console.error('Error updating profile:', error);
            showToast(error.message || 'An error occurred', 'error');
            
            // Reset button
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        });
}

// Initiate Transaction
function initiateTransaction(walletId) {
    walletAPI.wallet.getAll()
        .then(response => {
            if (!response.success) {
                showToast('Error loading wallets', 'error');
                return;
            }
            
            const wallets = response.data;
            const sourceWallet = wallets.find(w => w.wallet_id == walletId);
            
            if (!sourceWallet) {
                showToast('Wallet not found', 'error');
                return;
            }
            
            // Create a list of other wallets for transfers
            const otherWallets = wallets.filter(w => w.wallet_id != walletId);
            let walletOptions = '';
            
            otherWallets.forEach(wallet => {
                walletOptions += `<option value="${wallet.wallet_id}">Wallet #${wallet.wallet_id} (${wallet.currency_code}) - Balance: ${formatCurrency(wallet.balance, wallet.currency_code)}</option>`;
            });
            
            const modal = document.createElement('div');
            modal.className = 'modal';
            modal.innerHTML = `
                <div class="modal-content">
                    <div class="modal-header">
                        <h2><i class="fas fa-exchange-alt"></i> Transfer Funds</h2>
                        <button class="close-btn" onclick="this.parentElement.parentElement.parentElement.remove()">&times;</button>
                    </div>
                    <form id="transferForm" class="modal-form">
                        <input type="hidden" id="sourceWalletId" value="${walletId}">
                        
                        <div class="wallet-info-box">
                            <h3>From Wallet</h3>
                            <p>Wallet #${sourceWallet.wallet_id} (${sourceWallet.currency_code})</p>
                            <p class="wallet-balance">Available Balance: ${formatCurrency(sourceWallet.balance, sourceWallet.currency_code)}</p>
                        </div>
                        
                        <div class="input-group">
                            <label for="transferType">Transfer Type:</label>
                            <select id="transferType" class="input-field" required onchange="toggleTransferFields()">
                                <option value="">Select transfer type</option>
                                <option value="internal">To Another Wallet</option>
                                <option value="external">To External Account</option>
                            </select>
                        </div>
                        
                        <div id="internalTransferFields" style="display: none;">
                            <div class="input-group">
                                <label for="targetWalletId">Destination Wallet:</label>
                                <select id="targetWalletId" class="input-field">
                                    <option value="">Select destination wallet</option>
                                    ${walletOptions}
                                </select>
                            </div>
                        </div>
                        
                        <div id="externalTransferFields" style="display: none;">
                            <div class="input-group">
                                <label for="recipientName">Recipient Name:</label>
                                <input type="text" id="recipientName" class="input-field" placeholder="Full name of recipient">
                            </div>
                            <div class="input-group">
                                <label for="accountNumber">Account Number:</label>
                                <input type="text" id="accountNumber" class="input-field" placeholder="Recipient's account number">
                            </div>
                            <div class="input-group">
                                <label for="bankName">Bank Name:</label>
                                <input type="text" id="bankName" class="input-field" placeholder="Recipient's bank name">
                            </div>
                        </div>
                        
                        <div class="input-group">
                            <label for="transferAmount">Amount (${sourceWallet.currency_code}):</label>
                            <input type="number" id="transferAmount" class="input-field" min="0.01" step="0.01" required placeholder="Amount to transfer" max="${sourceWallet.balance}">
                            <small>Maximum: ${formatCurrency(sourceWallet.balance, sourceWallet.currency_code)}</small>
                        </div>
                        
                        <div class="input-group">
                            <label for="transferDescription">Description (Optional):</label>
                            <textarea id="transferDescription" class="input-field" rows="2" placeholder="Add a note for this transfer"></textarea>
                        </div>
                        
                        <div class="modal-actions">
                            <button type="submit" class="btn primary-btn">
                                <i class="fas fa-paper-plane"></i> Send Transfer
                            </button>
                            <button type="button" class="btn secondary-btn" onclick="this.parentElement.parentElement.parentElement.parentElement.remove()">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                    </form>
                </div>
            `;
            document.body.appendChild(modal);

            // Close modal when clicking outside
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.remove();
                }
            });
            
            // Toggle transfer fields
            window.toggleTransferFields = function() {
                const transferType = document.getElementById('transferType').value;
                const internalFields = document.getElementById('internalTransferFields');
                const externalFields = document.getElementById('externalTransferFields');
                
                if (transferType === 'internal') {
                    internalFields.style.display = 'block';
                    externalFields.style.display = 'none';
                } else if (transferType === 'external') {
                    internalFields.style.display = 'none';
                    externalFields.style.display = 'block';
                } else {
                    internalFields.style.display = 'none';
                    externalFields.style.display = 'none';
                }
            };
            
            // Form submission
            const form = document.getElementById('transferForm');
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                
                const sourceWalletId = parseInt(document.getElementById('sourceWalletId').value);
                const transferType = document.getElementById('transferType').value;
                const amount = parseFloat(document.getElementById('transferAmount').value);
                const description = document.getElementById('transferDescription').value.trim();
                
                if (!transferType || !amount || isNaN(amount) || amount <= 0) {
                    showToast('Please provide a valid transfer type and amount', 'error');
                    return;
                }
                
                if (amount > sourceWallet.balance) {
                    showToast('Transfer amount exceeds available balance', 'error');
                    return;
                }
                
                try {
                    const submitBtn = form.querySelector('button[type="submit"]');
                    const originalBtnText = submitBtn.innerHTML;
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                    submitBtn.disabled = true;
                    
                    if (transferType === 'internal') {
                        const targetWalletId = parseInt(document.getElementById('targetWalletId').value);
                        
                        if (!targetWalletId) {
                            showToast('Please select a destination wallet', 'error');
                            submitBtn.innerHTML = originalBtnText;
                            submitBtn.disabled = false;
                            return;
                        }
                        
                        // Show confirmation
                        if (!confirm(`Transfer ${formatCurrency(amount, sourceWallet.currency_code)} to Wallet #${targetWalletId}?`)) {
                            submitBtn.innerHTML = originalBtnText;
                            submitBtn.disabled = false;
                            return;
                        }
                        
                        // Process internal transfer
                        const response = await walletAPI.wallet.transferInternal(
                            sourceWalletId,
                            targetWalletId,
                            amount,
                            description
                        );
                        
                        if (response.success) {
                            showToast('Transfer completed successfully', 'success');
                            
                            // Show transfer details if available
                            if (response.data) {
                                const details = response.data;
                                console.log('Transfer details:', details);
                                
                                // Show more detailed success message
                                let successMsg = `Transfer successful!\n`;
                                
                                if (details.currency_sent !== details.currency_received) {
                                    successMsg += `${formatCurrency(details.amount_sent, details.currency_sent)} sent\n`;
                                    successMsg += `${formatCurrency(details.amount_received, details.currency_received)} received\n`;
                                    successMsg += `Exchange rate: ${details.exchange_rate}\n`;
                                    successMsg += `Fee: ${formatCurrency(details.exchange_fee, details.currency_sent)}\n`;
                                }
                                
                                alert(successMsg);
                            }
                            
                            fetchWallets();
                            fetchTransactions();
                            modal.remove();
                        } else {
                            showToast(response.message || 'Transfer failed', 'error');
                            submitBtn.innerHTML = originalBtnText;
                            submitBtn.disabled = false;
                        }
                    } else if (transferType === 'external') {
                        const recipientName = document.getElementById('recipientName').value.trim();
                        const accountNumber = document.getElementById('accountNumber').value.trim();
                        const bankName = document.getElementById('bankName').value.trim();
                        
                        if (!recipientName || !accountNumber || !bankName) {
                            showToast('Please fill in all recipient details', 'error');
                            submitBtn.innerHTML = originalBtnText;
                            submitBtn.disabled = false;
                            return;
                        }
                        
                        // Show confirmation
                        if (!confirm(`Transfer ${formatCurrency(amount, sourceWallet.currency_code)} to ${recipientName}?`)) {
                            submitBtn.innerHTML = originalBtnText;
                            submitBtn.disabled = false;
                            return;
                        }
                        
                        // Process external transfer
                        const response = await walletAPI.wallet.transferExternal(
                            sourceWalletId,
                            recipientName,
                            accountNumber,
                            bankName,
                            amount,
                            description
                        );
                        
                        if (response.success) {
                            showToast('External transfer initiated successfully', 'success');
                            fetchWallets();
                            fetchTransactions();
                            modal.remove();
                        } else {
                            showToast(response.message || 'Transfer failed', 'error');
                            submitBtn.innerHTML = originalBtnText;
                            submitBtn.disabled = false;
                        }
                    }
                } catch (error) {
                    console.error('Error during transfer:', error);
                    showToast(error.message || 'An error occurred. Please try again.', 'error');
                    
                    const submitBtn = form.querySelector('button[type="submit"]');
                    submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Send Transfer';
                    submitBtn.disabled = false;
                }
            });
        })
        .catch(error => {
            console.error('Error loading wallets:', error);
            showToast('Failed to load wallets', 'error');
        });
}
    
    // Toggle transfer type fields
    const transferTypeSelect = document.getElementById('transferType');
    transferTypeSelect.addEventListener('change', () => {
        const internalFields = document.getElementById('internalTransferFields');
        const externalFields = document.getElementById('externalTransferFields');
        
        if (transferTypeSelect.value === 'internal') {
            internalFields.style.display = 'block';
            externalFields.style.display = 'none';
        } else if (transferTypeSelect.value === 'external') {
            internalFields.style.display = 'none';
            externalFields.style.display = 'block';
        } else {
            internalFields.style.display = 'none';
            externalFields.style.display = 'none';
        }
    });
    
    // Form submission
    const transferForm = document.getElementById('transferForm');
    transferForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const sourceWalletId = parseInt(document.getElementById('sourceWalletId').value);
        const transferType = document.getElementById('transferType').value;
        const amount = parseFloat(document.getElementById('transferAmount').value);
        const description = document.getElementById('transferDescription').value.trim();
        
        if (!transferType || !amount || isNaN(amount) || amount <= 0) {
            showToast('Please provide a valid transfer type and amount', 'error');
            return;
        }
        
        // Show loading state
        const submitBtn = transferForm.querySelector('button[type="submit"]');
        const originalBtnText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
        submitBtn.disabled = true;
        
        if (transferType === 'internal') {
            const targetWalletId = parseInt(document.getElementById('targetWalletId').value);
            if (!targetWalletId) {
                showToast('Please select a destination wallet', 'error');
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
                return;
            }
            
            try {
                const response = await walletAPI.wallet.transferInternal(
                    sourceWalletId,
                    targetWalletId,
                    amount,
                    description
                );
                
                if (response.success) {
                    showToast('Transfer completed successfully', 'success');
                    fetchWallets();
                    fetchTransactions();
                    modal.remove();
                } else {
                    showToast(response.message || 'Transfer failed', 'error');
                    submitBtn.innerHTML = originalBtnText;
                    submitBtn.disabled = false;
                }
            } catch (error) {
                console.error('Error during transfer:', error);
                showToast(error.message || 'An error occurred. Please try again.', 'error');
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
            }
            
        } else if (transferType === 'external') {
            const recipientName = document.getElementById('recipientName').value.trim();
            const accountNumber = document.getElementById('accountNumber').value.trim();
            const bankName = document.getElementById('bankName').value.trim();
            
            if (!recipientName || !accountNumber || !bankName) {
                showToast('Please fill in all recipient details', 'error');
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
                return;
            }
            
            try {
                const response = await walletAPI.wallet.transferExternal(
                    sourceWalletId,
                    recipientName,
                    accountNumber,
                    bankName,
                    amount,
                    description
                );
                
                if (response.success) {
                    showToast('External transfer initiated successfully', 'success');
                    fetchWallets();
                    fetchTransactions();
                    modal.remove();
                } else {
                    showToast(response.message || 'Transfer failed', 'error');
                    submitBtn.innerHTML = originalBtnText;
                    submitBtn.disabled = false;
                }
            } catch (error) {
                console.error('Error during external transfer:', error);
                showToast(error.message || 'An error occurred. Please try again.', 'error');
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
            }
        }
    });

// Initiate external wallet transfer
function initiateExternalTransfer(sourceWalletId, recipientName, accountNumber, bankName, amount, description = '') {
    walletAPI.wallet.transferExternal(sourceWalletId, recipientName, accountNumber, bankName, amount, description)
        .then(response => {
            if (response.success) {
                showToast('External transfer initiated successfully', 'success');
                fetchWallets();
                fetchTransactions();
                // Close modal if open
                const modal = document.querySelector('.modal');
                if (modal) modal.remove();
            } else {
                showToast(response.message || 'Transfer failed', 'error');
            }
        })
        .catch(error => {
            console.error('Error during external transfer:', error);
            showToast(error.message || 'An error occurred. Please try again.', 'error');
        });
}

// Update password function
function updatePassword(e) {
    e.preventDefault();
    
    const currentPassword = document.getElementById('currentPassword').value;
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if (!currentPassword || !newPassword || !confirmPassword) {
        showToast('Please fill in all password fields', 'error');
        return;
    }
    
    if (newPassword !== confirmPassword) {
        showToast('New passwords do not match', 'error');
        return;
    }
    
    if (newPassword.length < 8) {
        showToast('Password must be at least 8 characters long', 'error');
        return;
    }
    
    // Show loading state
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalBtnText = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
    submitBtn.disabled = true;
    
    walletAPI.auth.updatePassword(currentPassword, newPassword)
        .then(response => {
            if (response.success) {
                showToast('Password updated successfully', 'success');
                // Clear the form
                document.getElementById('passwordForm').reset();
            } else {
                showToast(response.message || 'Failed to update password', 'error');
            }
            
            // Reset button
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        })
        .catch(error => {
            console.error('Error updating password:', error);
            showToast(error.message || 'An error occurred', 'error');
            
            // Reset button
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        });
}

// Toast Notification Function
function showToast(message, type = 'info') {
    // Remove any existing toasts
    const existingToasts = document.querySelectorAll('.toast');
    existingToasts.forEach(toast => toast.remove());
    
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    
    let icon = '';
    switch (type) {
        case 'success':
            icon = '<i class="fas fa-check-circle"></i>';
            break;
        case 'error':
            icon = '<i class="fas fa-exclamation-circle"></i>';
            break;
        case 'warning':
            icon = '<i class="fas fa-exclamation-triangle"></i>';
            break;
        case 'info':
        default:
            icon = '<i class="fas fa-info-circle"></i>';
            break;
    }
    
    toast.innerHTML = `
        <div class="toast-content">
            <div class="toast-icon">${icon}</div>
            <div class="toast-message">${message}</div>
            <button class="toast-close">&times;</button>
        </div>
    `;
    
    document.body.appendChild(toast);
    
    // Add active class after a small delay to trigger animation
    setTimeout(() => toast.classList.add('active'), 10);
    
    // Close button functionality
    const closeBtn = toast.querySelector('.toast-close');
    closeBtn.addEventListener('click', () => {
        toast.classList.remove('active');
        setTimeout(() => toast.remove(), 300);
    });
    
    // Auto close after 5 seconds
    setTimeout(() => {
        if (document.body.contains(toast)) {
            toast.classList.remove('active');
            setTimeout(() => toast.remove(), 300);
        }
    }, 5000);
}

// Utility Function for Result Display
function showResult(message, type, element) {
    if (element) {
        element.innerText = message;
        element.className = 'result-message';
        
        if (type === 'success') {
            element.classList.add('success');
        } else if (type === 'error') {
            element.classList.add('error');
        } else if (type === 'info') {
            element.classList.add('info');
        }
    } else {
        console.log(`${type.toUpperCase()}: ${message}`);
    }
}

// Helper Functions
function formatCurrency(amount, currencyCode) {
    const formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: currencyCode || 'USD',
        minimumFractionDigits: 2
    });
    
    return formatter.format(amount);
}

function formatStatus(status) {
    return status.charAt(0) + status.slice(1).toLowerCase().replace('_', ' ');
}

function formatTransactionType(type) {
    const typeMap = {
        'DEPOSIT': 'Deposit',
        'WITHDRAWAL': 'Withdrawal',
        'TRANSFER_SENT': 'Transfer Sent',
        'TRANSFER_RECEIVED': 'Transfer Received',
        'PAYMENT': 'Payment',
        'REFUND': 'Refund'
    };
    
    return typeMap[type] || type;
}

function getTransactionTypeClass(type) {
    const classMap = {
        'DEPOSIT': 'type-deposit',
        'WITHDRAWAL': 'type-withdrawal',
        'TRANSFER_SENT': 'type-transfer',
        'TRANSFER_RECEIVED': 'type-transfer',
        'PAYMENT': 'type-payment',
        'REFUND': 'type-deposit'
    };
    
    return classMap[type] || '';
}

function formatAccountType(type) {
    const typeMap = {
        'CHECKING': 'Checking',
        'SAVINGS': 'Savings',
        'OTHER': 'Other'
    };
    
    return typeMap[type] || type;
}

function maskAccountNumber(accountNumber) {
    if (!accountNumber) return '';
    
    // Keep only first and last 4 digits visible
    const length = accountNumber.length;
    if (length <= 8) return accountNumber;
    
    const firstFour = accountNumber.substring(0, 4);
    const lastFour = accountNumber.substring(length - 4);
    const masked = '*'.repeat(length - 8);
    
    return `${firstFour}${masked}${lastFour}`;
}

function getCardTypeIcon(cardType) {
    switch (cardType) {
        case 'VISA':
            return '<i class="fab fa-cc-visa"></i>';
        case 'MASTERCARD':
            return '<i class="fab fa-cc-mastercard"></i>';
        case 'AMEX':
            return '<i class="fab fa-cc-amex"></i>';
        case 'DISCOVER':
            return '<i class="fab fa-cc-discover"></i>';
        default:
            return '<i class="fas fa-credit-card"></i>';
    }
}

function getCardBackground(cardType) {
    switch (cardType) {
        case 'VISA':
            return 'linear-gradient(135deg, #43a047, #1e88e5)';
        case 'MASTERCARD':
            return 'linear-gradient(135deg, #ff9800, #f44336)';
        case 'AMEX':
            return 'linear-gradient(135deg, #3949ab, #1a237e)';
        case 'DISCOVER':
            return 'linear-gradient(135deg, #ff7043, #f57c00)';
        default:
            return 'linear-gradient(135deg, #78909c, #37474f)';
    }
}