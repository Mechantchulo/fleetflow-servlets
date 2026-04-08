document.addEventListener("DOMContentLoaded", () => {
    // 1. Table Row Hover Effects
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

    // 2. Clear Filters Button Logic
    const clearBtn = document.getElementById("clearFilters");
    
    if (clearBtn) {
        clearBtn.addEventListener("click", () => {
            // Reset all select dropdowns
            document.querySelectorAll(".filter-form select").forEach(select => {
                select.selectedIndex = 0;
            });
            
            // Clear all date inputs
            document.querySelectorAll(".filter-form input[type='date']").forEach(input => {
                input.value = "";
            });

            // Automatically submit the form to refresh the data
            document.querySelector(".filter-form").submit();
        });
    }

    // 3. Dynamic Greeting based on time
    const subtitle = document.querySelector(".subtitle");
    if (subtitle) {
        const hour = new Date().getHours();
        let greeting = "Welcome back";
        
        if (hour < 12) greeting = "Good morning";
        else if (hour < 18) greeting = "Good afternoon";
        else greeting = "Good evening";

        subtitle.innerHTML = subtitle.innerHTML.replace("Welcome back", greeting);
    }
});