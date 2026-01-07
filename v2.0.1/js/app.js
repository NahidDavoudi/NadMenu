// Main Application - Load data and initialize components
class MenuApp {
    constructor() {
        this.categories = [];
        this.products = [];
        this.currentCategory = null;
        this.init();
    }

    async init() {
        await this.loadData();
        this.renderCategories();
        this.renderProducts();
        this.initCarousel();
        this.initCardAnimations();
    }

    async loadData() {
        try {
            const response = await fetch('data/products.json');
            const data = await response.json();
            this.categories = data.categories;
            // Set first category as default
            if (this.categories.length > 0) {
                this.currentCategory = this.categories[0].id;
            }
        } catch (error) {
            console.error('Error loading products data:', error);
        }
    }

    renderCategories() {
        const swiperWrapper = document.querySelector('.category-swiper .swiper-wrapper');
        if (!swiperWrapper) return;

        swiperWrapper.innerHTML = this.categories.map((category, index) => `
            <div class="swiper-slide">
                <button 
                    class="category-btn flex flex-col items-center justify-center p-2 sm:p-3 rounded-2xl transition-all duration-300 ${index === 0 ? 'bg-amber-600 text-white' : 'bg-amber-800/50 text-amber-100 hover:bg-amber-700'}"
                    data-category="${category.id}"
                >
                    <span class="text-2xl sm:text-3xl mb-1">${category.icon}</span>
                    <span class="text-xs sm:text-sm font-medium whitespace-nowrap">${category.name}</span>
                </button>
            </div>
        `).join('');

        // Add click event listeners to category buttons
        document.querySelectorAll('.category-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.selectCategory(e.currentTarget.dataset.category);
            });
        });
    }

    selectCategory(categoryId) {
        this.currentCategory = categoryId;
        
        // Update active button styles
        document.querySelectorAll('.category-btn').forEach(btn => {
            if (btn.dataset.category === categoryId) {
                btn.classList.remove('bg-amber-800/50', 'text-amber-100', 'hover:bg-amber-700');
                btn.classList.add('bg-amber-600', 'text-white');
            } else {
                btn.classList.remove('bg-amber-600', 'text-white');
                btn.classList.add('bg-amber-800/50', 'text-amber-100', 'hover:bg-amber-700');
            }
        });

        // Re-render products with animation
        this.renderProducts(true);
    }

    renderProducts(animate = false) {
        const productsGrid = document.getElementById('products-grid');
        if (!productsGrid) return;

        const category = this.categories.find(c => c.id === this.currentCategory);
        if (!category) return;

        const products = category.products;

        productsGrid.innerHTML = products.map(product => `
            <div class="product-card bg-white rounded-2xl shadow-lg overflow-hidden transform transition-all duration-300 hover:scale-[1.02] hover:shadow-xl">
                <div class="relative">
                    <img 
                        src="${product.image}" 
                        alt="${product.name}" 
                        class="w-full h-32 sm:h-40 object-cover"
                        onerror="this.src='assets/images/placeholder.jpg'"
                    >
                    ${product.isPopular ? `
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded-full">
                            پرطرفدار
                        </span>
                    ` : ''}
                </div>
                <div class="p-3 sm:p-4">
                    <h3 class="font-bold text-gray-800 text-sm sm:text-base mb-1">${product.name}</h3>
                    <p class="text-gray-500 text-xs sm:text-sm mb-2 line-clamp-2">${product.description}</p>
                    <div class="flex items-center justify-between">
                        <span class="text-amber-700 font-bold text-sm sm:text-base">
                            ${this.formatPrice(product.price)}
                        </span>
                        <button class="bg-amber-600 text-white p-2 rounded-full hover:bg-amber-700 transition-colors">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        `).join('');

        // Trigger animations if needed
        if (animate && typeof animateCards === 'function') {
            animateCards();
        }
    }

    formatPrice(price) {
        return new Intl.NumberFormat('fa-IR').format(price) + ' تومان';
    }

    initCarousel() {
        if (typeof initCategoryCarousel === 'function') {
            initCategoryCarousel();
        }
    }

    initCardAnimations() {
        if (typeof initCardAnimations === 'function') {
            initCardAnimations();
        }
    }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.menuApp = new MenuApp();
});
