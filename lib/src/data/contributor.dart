/// Someone who worked on the app and will be recognized for it.
class Contributor {
	/// The list of all contributors.
	/// 
	/// The most recent contributors go at the top of the list to keep it relveant.
	static const List<Contributor> contributors = [
		Contributor(
			name: "David T.",
			gradYear: "'23",
			title: "Frontend",
			url: "mailto:davidtbassist@gmail.com",
			linkName: "Email me",
			imageName: "images/contributors/david-tarrab.jpg",
			description: "David has been working on RamLife since sophomore year and "
				"mainly works on creating the user interface and page layouts."
		),
		Contributor(
			name: "Brayden K.",
			gradYear: "'23",
			title: "Backend",
			url: "https://github.com/BraydenKO",
			linkName: "See my other projects",
			imageName: "images/contributors/brayden-kohler.jpg",
			description: "Brayden joined the RamLife team as a sophomore and manages "
				"the logic of the app. He also handles the database and other services."
		),
		Contributor(
			name: "Josh Todes",
			gradYear: "'23",
			title: "Middleware and Apple Expert",
			url: "mailto:todesj@ramaz.org",
			linkName: "Email me",
			imageName: "images/contributors/josh-todes.jpg",
			description: "Josh worked on the iPhone app since he was a Freshman "
				"and now handles tying the logic and graphics together seamlessly."
		),
		Contributor(
			name: "Mr. Vovsha",
			gradYear: "'21",  // TODO
			title: "Faculty Advisor",
			url: "mailto:evovsha@ramaz.org",
			linkName: "Email me",
			imageName: "images/contributors/eli-vovsha.jpg",
			description: "Mr. Vovsha led the group since its conception, and has worked"
				" tirelessly with the school to help bring RamLife where it is today."
		),
		Contributor(
			name: "Levi Lesches",
			gradYear: "'21",
			title: "Creator and Head Programmer",
			url: "https://github.com/Levi-Lesches",
			linkName: "See my other projects",
			imageName: "images/contributors/levi-lesches.jpg",
			description: "Levi created RamLife when he was a freshman and expanded it "
				"over four years. He wrote all the code and went through many iterations."
		),
	];

	/// The name of the contributor.
	final String name;

	/// The graduation year of the contributor.
	/// 
	/// This can be years worked at Ramaz (for faculty).
	final String gradYear;

	/// The title of the contributor.
	final String title;

	/// A link to a webpage about this contributor. 
	/// 
	/// Can also be a mailto URL.
	final String url;

	/// A label to show for [url]. 
	/// 
	/// Not everyone recognizes github.com or `mailto`, so this should be used
	/// to describe what resource the link will take you to.
	final String linkName;

	/// How this person contributed to RamLife. 
	/// 
	/// Limit this to 150 characters so it looks nice on web and mobile.
	final String description;

	/// The path for the contributor's picture.
	final String imageName;

	/// A constructor that defines what data a Contributor should have.
	const Contributor({
		required this.description,
		required this.gradYear,
		required this.url,
		required this.linkName,
		required this.name,
		required this.title,
		required this.imageName,
	});
}
