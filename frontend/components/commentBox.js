
function createCommentBox(comment) {
	const markup =
		`
			<div class="flex">
				<div class="flex-1 border rounded-lg px-4 py-2 sm:px-6 sm:py-4 leading-relaxed">
					<strong>${comment.user}</strong> 
					<span class="text-xs text-gray-400">${new Date(comment.published_date).toLocaleString()}</span>
					<p class="text-sm">
						${comment.content}
					</p>
				</div>
			</div>
		`
	let div = document.createElement("div");
	div.innerHTML = markup;
	return div;
}

export { createCommentBox as default };
