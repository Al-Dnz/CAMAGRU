function send()
{
	var login = document.getElementById("login");
	var password = document.getElementById("password");
	var email = document.getElementById("email");

	data = 
	{
		login: login.value,
		password: password.value,
		email: email.value
	}

	fetch('http://0.0.0.0:1337/register', {
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