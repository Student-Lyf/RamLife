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
			email: "davidtbassist@gmail.com",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "David has been working on RamLife since sophomore year and "
				"mainly works on creating the user interface and page layouts."
		),
		Contributor(
			name: "Brayden K.",
			gradYear: "'23",
			title: "Backend",
			email: "kohlerb@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Brayden joined the RamLife team as a sophomore and manages "
				"the logic of the app. He also handles the database and other services."
		),
		Contributor(
			name: "Joshua T.",
			gradYear: "'23",
			title: "Middleware and Apple Expert",
			email: "todesj@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Joshua worked on the iPhone app since he was a FreshmanHe "
				"and now handles tying the logic and the graphics seamlessly."
		),
		Contributor(
			name: "Levi Lesches",
			gradYear: "'21",
			title: "Creator and Head Programmer",
			email: "levilesches@gmail.com",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Levi created RamLife when he was a freshman and expanded it "
				"over four years. He wrote all the code and went through many iterations."
		),
		Contributor(
			name: "Mr. Vovsha",
			gradYear: "'21",  // TODO
			title: "Faculty Advisor",
			email: "evovsha@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Mr. Vovsha led the group since its conception, and has worked"
				" tirelessly with the school to help bring RamLife where it is today."
		)
	];

	/// The name of the contributor.
	final String name;

	/// The graduation year of the contributor.
	/// 
	/// This can be years worked at Ramaz (for faculty).
	final String gradYear;

	/// The title of the contributor.
	final String title;

	/// The email of the contributor.
	/// 
	/// Make this a non-Ramaz email, since it should stay after graduation.
	final String email;

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
		required this.email,
		required this.name,
		required this.title,
		required this.imageName,
	});
}
