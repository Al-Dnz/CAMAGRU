function send()
{
	var login = document.getElementById("login");
	var password = document.getElementById("password");

	data = 
	{
		login: login.value,
		password: password.value,
	}

	fetch('http://0.0.0.0:1337/connect', {
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
		if (data.token != null)
			document.cookie = "token" + "=" + data.token
		login.value = "";
		password.value = "";
		window.location.href = './index.html';
	})
	.catch(async (error) => {
		data = await error;
		console.error('error:', data.error); 
	});
}