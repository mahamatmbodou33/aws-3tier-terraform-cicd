document.addEventListener("DOMContentLoaded", () => {
    const healthStatus = document.getElementById("health-status");

    const statusData = {
        status: "Healthy",
        service: "App2 Backend Service",
        environment: "Development",
        version: "1.0.0"
    };

    setTimeout(() => {
        healthStatus.textContent = `${statusData.status} - ${statusData.service}`;
    }, 600);

    console.log("App2 service page loaded successfully");
});