// console.log("hello form uplaod");

// const input = document.getElementById("input");

// const output = document.getElementById("output");
// let imagesArray = [];

// if (input)
// {
// 	input.addEventListener("change", () => {
// 		const file = input.files;
// 		imagesArray.push(file[0]);
// 		displayImages();
// 	});
// }


// function displayImages() {
//   let images = "";
//   imagesArray.forEach((image, index) => {
//     images += `<div class="image">
// 				  <img src="${URL.createObjectURL(image)}" alt="image">
// 				  <span onclick="deleteImage(${index})">&times;</span>
// 				</div>`;
//   });
//   output.innerHTML = images;
// }

// function deleteImage(index) {
//   imagesArray.splice(index, 1);
//   displayImages();
// }

var myBlob;

window.addEventListener('load', function() {
	document.querySelector('input[type="file"]').addEventListener('change', function() {
		if (this.files && this.files[0]) {
			var img = document.querySelector('img');
			img.onload = () => {
				URL.revokeObjectURL(img.src);  // no longer needed, free memory
			}
			var file = URL.createObjectURL(this.files[0]); // set src to blob url
			img.src = file; // set src to blob url
			myBlob = fileToBlob(this.files[0])
			// console.log("file =>");
			// console.log(myBlob);
		}
	});
});

function fileToBlob(file) {
	return new Blob([file], { type: file.type });
}

function postUpload()
{
	var img = document.querySelector('img');
	if (!myBlob)
		return;
	console.log(myBlob);
	fetch('http://0.0.0.0:1337/pictures', {
		method: "POST",
		headers: {
			'Content-Type': 'multipart/form-data',
		},
		body: myBlob,
	})
	.then((response) => {
		if (response.ok)
			 return response.json();
		else
			return Promise.reject(response.json()); 
	  })
	.then((data) => {
		console.log('success:', data);
	})
	// .catch(async (error) => {
	// 	data = await error;
	// 	console.error('error:', data.error); 
	// });
}