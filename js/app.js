/**
 * Recipe App Interactivity (theme-toggle, mobile-menu, modal)
 */

document.addEventListener('DOMContentLoaded', () => {
    // === 1. Theme Toggle Functionality ===
    const themeToggle = document.querySelector('.theme-toggle');
    const htmlElement = document.documentElement;

    // Check for saved theme preference or system preference
    const savedTheme = localStorage.getItem('theme');
    const prefersDark = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)').matches : false;

    // Apply initial theme
    if (savedTheme === 'dark' || (!savedTheme && prefersDark)) {
        htmlElement.setAttribute('data-theme', 'dark');
    } else {
        htmlElement.removeAttribute('data-theme'); // Light mode is default
    }

    // Update the icon based on the current theme (using emojis for simplicity/cross-platform)
    function updateThemeIcon() {
        const iconContainer = themeToggle ? themeToggle.querySelector('.theme-icon') : null;
        if (!iconContainer) return;
        
        if (htmlElement.getAttribute('data-theme') === 'dark') {
            iconContainer.textContent = '☀️'; // Sun icon for light mode switch
        } else {
            iconContainer.textContent = '🌙'; // Moon icon for dark mode switch
        }
    }
    
    if (themeToggle) {
        updateThemeIcon(); // Initial icon update

        // Toggle theme on click
        themeToggle.addEventListener('click', () => {
            if (htmlElement.hasAttribute('data-theme')) {
                htmlElement.removeAttribute('data-theme');
                localStorage.setItem('theme', 'light');
            } else {
                htmlElement.setAttribute('data-theme', 'dark');
                localStorage.setItem('theme', 'dark');
            }
            updateThemeIcon();
        });
    }

    // === 2. Mobile Menu Toggle Functionality ===
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const navMenu = document.querySelector('.nav-menu');

    if (mobileMenuToggle && navMenu) {
        mobileMenuToggle.addEventListener('click', () => {
            navMenu.classList.toggle('open');
            mobileMenuToggle.classList.toggle('open');
        });

        // Close menu when a link is clicked (good for UX)
        navMenu.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('open');
                mobileMenuToggle.classList.remove('open');
            });
        });
    }
    
    // === 3. Modal Functionality (Recipe Details) ===
    
    const modal = document.getElementById('recipeModal');
    const modalCloseBtn = document.querySelector('.modal-close');
    // Select all buttons in the recipe cards that trigger the modal
    const recipeViewButtons = document.querySelectorAll('.recipe-card .btn-primary');

    /**
     * Shows the modal by changing its display style.
     */
    function openModal() {
        if (modal) {
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden'; // Prevent scrolling background
        }
    }

    /**
     * Hides the modal by changing its display style.
     */
    function closeModal() {
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = ''; // Restore scrolling
        }
    }
    
    // Attach event listeners to open the modal using the dedicated button
    recipeViewButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault(); // Stop form submission if inside a form, though here it's just a div.
            // In a real application, you would load dynamic data based on the clicked card
            openModal();
        });
    });

    // Attach event listener to the close button
    if (modalCloseBtn) {
        modalCloseBtn.addEventListener('click', closeModal);
    }
    
    // Attach event listener to close when clicking outside the content (on the overlay)
    if (modal) {
        modal.querySelector('.modal-overlay').addEventListener('click', closeModal);
    }

    // Attach event listener to close on ESC key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && modal && modal.style.display === 'block') {
            closeModal();
        }
    });

    // === 4. Search and Filter (Mock functionality) ===
    
    const searchForm = document.querySelector('.search-form');
    if (searchForm) {
        searchForm.addEventListener('submit', (e) => {
            e.preventDefault();
            console.log('Search form submitted! Starting recipe filtration...');
            // In a live app, this would trigger an API call and render results.
        });
    }

    const filters = document.querySelectorAll('.filter-select, .filter-input');
    filters.forEach(filter => {
        filter.addEventListener('change', () => {
            console.log('Filter changed! Ready to re-run recipe filtering.');
        });
    });
});
