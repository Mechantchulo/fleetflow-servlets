document.addEventListener("DOMContentLoaded", () => {
    
    // 1. Dynamic Greeting based on time of day
    const subtitle = document.querySelector(".subtitle");
    if (subtitle) {
        const hour = new Date().getHours();
        let greeting = "Welcome back";
        
        if (hour < 12) greeting = "Good morning";
        else if (hour < 18) greeting = "Good afternoon";
        else greeting = "Good evening";

        subtitle.innerHTML = subtitle.innerHTML.replace("Welcome back", greeting);
    }

    // 2. Table Row Hover Effects
    const tableRows = document.querySelectorAll(".data-table tbody tr");
    tableRows.forEach(row => {
        row.addEventListener("mouseenter", () => {
            row.style.backgroundColor = "#f8fafc";
            row.style.transition = "background-color 0.2s ease";
        });
        row.addEventListener("mouseleave", () => {
            row.style.backgroundColor = "transparent";
        });
    });

    // 3. Form Validation: Enforce backend rule (Date cannot be in the past)
    const dateInput = document.getElementById("date");
    if (dateInput) {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        
        const formattedToday = `${yyyy}-${mm}-${dd}`;
        dateInput.setAttribute("min", formattedToday);
    }

    // 4. Form UX: Prevent double submissions
    const tripForm = document.getElementById("tripForm");
    if (tripForm) {
        tripForm.addEventListener("submit", function() {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
                submitBtn.disabled = true;
                submitBtn.style.opacity = "0.8";
                submitBtn.style.cursor = "not-allowed";
            }
        });
    }
});