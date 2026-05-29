document.addEventListener("DOMContentLoaded", () => {

    console.log("Portfolio loaded successfully");

    const projectSection = document.querySelector("#projects");

    projectSection.addEventListener("mouseenter", () => {
        projectSection.style.transform = "scale(1.01)";
    });

    projectSection.addEventListener("mouseleave", () => {
        projectSection.style.transform = "scale(1)";
    });

});