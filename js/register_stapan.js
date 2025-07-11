const apiUrl = `http://${window.location.hostname}:5000`;

document.getElementById("registerStapanForm").onsubmit = async (event) => {
    event.preventDefault();

    const nume = document.getElementById("nume").value;
    const prenume = document.getElementById("prenume").value;
    const telefon = document.getElementById("telefon").value;
    const email = document.getElementById("email").value;
    const adresa = document.getElementById("adresa").value;
    const message = document.getElementById("responseMessage");

    const response = await fetch(apiUrl + "/register/stapan", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ nume, prenume, telefon, email, adresa }),
        credentials: 'include'
    });

    if (response.status == 201) {
        message.innerText = "Stapan profile completed!";
        message.style.color = "green";
        setTimeout(() => {
            window.location.href = "Login.html";
        }, 1000);
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