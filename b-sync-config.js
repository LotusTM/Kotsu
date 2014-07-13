module.exports = {
	files: ["css/*.css", "*.html", "js/*.js"],
	debugInfo: true,
	host: "192.168.1.2",
	ghostMode: {
		links: true,
		forms: true,
		scroll: true
	},
	server: {
		baseDir: "./",
		// index: "index.htm"
	},
	open: true,
	notify: true
};