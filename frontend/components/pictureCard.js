
function createCard(picture) {
	const markup =
		`<div id="pictureCard${picture.id}" style="display: block" class="max-w-sm max-w-md mx-auto rounded overflow-hidden shadow-lg" data-type="picture_card_template">
			<div class="font-bold text-xl mb-2">The Coldest Sunset yolo</div>
			<img class="w-full" src="${picture.path}" alt="Sunset in the mountains">
			<div class="px-6 py-4">
				<p class="text-gray-700 text-base"> ${picture.content} </p>
			</div>
			<div class="px-6 pt-4 pb-2">
				<span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">#photography</span>
				<span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">#travel</span>
				<span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">#nonrien</span>
			</div>
		</div>`

	let div = document.createElement("div");
	div.innerHTML = markup;
	return div;
}

export { createCard as default };



