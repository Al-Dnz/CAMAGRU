import { getHost } from "../config.js";

const host = await getHost('../config.json')

function send()
{
	const login = document.getElementById("login");
	const password = document.getElementById("password");
	const email = document.getElementById("email");

	let data = 
	{
		login: login.value,
		password: password.value,
		email: email.value
	}

	fetch(`http://${host}:1337/register`, {
		method: 'POST',
		headers: {
			// 'Content-Type': 'application/json',
		},
		body: JSON.stringify(data),
	})
	.then((response) => {
		if (response.ok)
			 return response.json();
		else
			return Promise.reject(response.json()); 
	  })
	.then((data) => {
		console.log('success:', data);
		login.value = "";
		password.value = "";
		email.value  = "";
	})
	.catch(async (error) => {
		data = await error;
		console.error('error:', data.error); 
	});
}

document.getElementById("registerBtn").addEventListener("click",() => {send()});