const apiUrl = `http://${window.location.hostname}:5000`;

document.getElementById("registerForm").onsubmit = async (event) => {
    event.preventDefault();

    const username = document.getElementById("username").value;
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirmPassword").value;
    const role = document.getElementById("role").value;
    const message = document.getElementById("responseMessage");

    if (password != confirmPassword) {
        message.innerText = "Passwords do not match!";
        message.style.color = "red";
        return;
    }

    const response = await fetch(apiUrl + "/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
        credentials: 'include'
    });

    if (response.status == 201) {
        message.innerText = "Registration successful!";
        message.style.color = "green";
        setTimeout(() => {
            window.location.href = "Register" + role + ".html";
        }, 1000);
    } else if (response.status == 409) {
        message.innerText = "Username already exists";
        message.style.color = "red";
    } else {
        message.innerText = "Internal server error, please try again later";
        message.style.color = "red";
    }
};