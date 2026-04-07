document.addEventListener("DOMContentLoaded", () => {
    // 1. Add interactive hover states to table rows
    const tableRows = document.querySelectorAll(".data-table tbody tr");
    
    tableRows.forEach(row => {
        row.addEventListener("mouseenter", () => {
            row.style.backgroundColor = "#f8fafc";
            row.style.cursor = "pointer";
            row.style.transition = "background-color 0.2s ease";
        });
        
        row.addEventListener("mouseleave", () => {
            row.style.backgroundColor = "transparent";
        });
    });

    // 2. Simple greeting logic based on time of day for the subtitle
    const subtitle = document.querySelector(".subtitle");
    if (subtitle) {
        const hour = new Date().getHours();
        let greeting = "Welcome back";
        
        if (hour < 12) greeting = "Good morning";
        else if (hour < 18) greeting = "Good afternoon";
        else greeting = "Good evening";

        // Replace "Welcome back" with time-specific greeting, keeping the username
        subtitle.innerHTML = subtitle.innerHTML.replace("Welcome back", greeting);
    }
});