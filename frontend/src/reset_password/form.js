import { getCookie, getHost, getPort} from "../config.js";

const host = await getHost('../config.json')
const port = 5000;

const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const code = urlParams.get('code');

function send()
{
	// const password = document.getElementById("password");
	const password = document.getElementById("newPassword");
	const confirmationDiv = document.querySelector("#confirmationDiv");
	const confirmationMessage = document.querySelector("#confirmationMessage");

	let data = 
	{
		password: password.value,
		reset_password_code: code
	}
	console.log("send =>");
	console.log(data);

	fetch(`http://${host}:${port}/reset_password`, {
		method: 'POST',
		headers: {},
		body: JSON.stringify(data),
	})
	.then((response) => {
		if (response.ok)
			 return response.json();
		else
			return Promise.reject(response.json()); 
	  })
	.then((data) => {
		password.value = "";
		console.log('success:', data);
		return data;
	})
	.then((data) => {
		// confirmationDiv.style.display = "";
		// confirmationMessage.innerHTML = `A mail with reset password link has been sent to ${data.email}`;
		window.location.href = '../connect/connect.html';
	})
	.catch(async (error) => {
		error = await error;
		window.alert(error.error);
		console.error('error:', error); 
	});
}

document.getElementById("updateBtnPassword").addEventListener("click",() => {send()});
