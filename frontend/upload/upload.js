import getHost from '../config.js';

const host = await getHost("../config.json");

var varBlob = null;

const inputBtn = document.querySelector('#input');
if (inputBtn)
	inputBtn.addEventListener('change', loadImg) 

const postUploadBtn = document.querySelector('#postUpload')
if (postUploadBtn)
	postUploadBtn.addEventListener('click',  postUpload);

function fileToBlob(file) {
	return new Blob([file], { type: file.type });
}

function loadImg()
{
	if (this.files && this.files[0]) {
		var img = document.querySelector('#myImg');
		img.onload = () => {
			URL.revokeObjectURL(img.src);  // no longer needed, free memory
		}
		var file = URL.createObjectURL(this.files[0]); // set src to blob url
		img.src = file; // set src to blob url
		varBlob = fileToBlob(this.files[0]);
	}
}

function postUpload()
{
	if (!varBlob)
	{
		console.error("no blob loaded")
		return;
	}
	fetch(`http://${host}:1337/pictures`, {
		method: "POST",
		headers: {
			'Content-Type': 'multipart/form-data',
		},
		body: varBlob,
	})
	.then((response) => {
		if (response.ok)
			 return response.json();
		else
			return Promise.reject(response.json()); 
	  })
	.then((data) => {
		console.log('success:', data);
		varBlob = null;
		var img = document.querySelector('#myImg');
		URL.revokeObjectURL(img.src);
		img.src = "";
	})
	// .catch(async (error) => {
	// 	data = await error;
	// 	console.error('error:', data.error); 
	// });
}





