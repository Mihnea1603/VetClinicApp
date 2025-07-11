const apiUrl = `http://${window.location.hostname}:5000`;

document.getElementById("registerMedicForm").onsubmit = async (event) => {
    event.preventDefault();

    const secretKey = document.getElementById("secret_key").value;
    const nume = document.getElementById("nume").value;
    const prenume = document.getElementById("prenume").value;
    const specializare = document.getElementById("specializare").value;
    const email = document.getElementById("email").value;
    const message = document.getElementById("responseMessage");

    const response = await fetch(apiUrl + "/register/medic", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ secretKey, nume, prenume, specializare, email }),
        credentials: 'include'
    });

    if (response.status == 201) {
        message.innerText = "Medic profile completed!";
        message.style.color = "green";
        setTimeout(() => {
            window.location.href = "Login.html";
        }, 1000);
    } else if (response.status == 400) {
        message.innerText = "Invalid secret key";
        message.style.color = "red";
    } else if (response.status == 403) {
        message.innerText = "Access denied. Please, create an account first!";
        message.style.color = "red";
        setTimeout(() => {
            window.location.href = "Register.html";
        }, 1500);
    } else {
        message.innerText = "Internal server error, please try again later";
        message.style.color = "red";
    }
};
