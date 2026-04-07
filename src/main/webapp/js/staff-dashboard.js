document.addEventListener("DOMContentLoaded", () => {
    
    // 1. Dynamic Greeting based on time of day
    const subtitle = document.querySelector(".subtitle");
    if (subtitle) {
        const hour = new Date().getHours();
        let greeting = "Welcome back";
        
        if (hour < 12) greeting = "Good morning";
        else if (hour < 18) greeting = "Good afternoon";
        else greeting = "Good evening";

        // Replace "Welcome back" with the time-specific greeting
        subtitle.innerHTML = subtitle.innerHTML.replace("Welcome back", greeting);
    }

    // 2. Table Row Hover Effects (Premium UI feel)
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

    // 3. Form Validation: Prevent selecting departure dates in the past
    const dateInput = document.getElementById("date");
    if (dateInput) {
        // Get today's date and format it as YYYY-MM-DD
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        
        const formattedToday = `${yyyy}-${mm}-${dd}`;
        
        // Set the minimum allowed date to today
        dateInput.setAttribute("min", formattedToday);
    }

    // 4. Form Submission UX (Optional but recommended)
    // Prevents double-clicking the submit button and shows loading state
    const requestForm = document.getElementById("requestForm");
    if (requestForm) {
        requestForm.addEventListener("submit", function(e) {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                // Change button text and disable it to prevent duplicate submissions
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
                submitBtn.disabled = true;
                submitBtn.style.opacity = "0.8";
                submitBtn.style.cursor = "not-allowed";
            }
        });
    }
});