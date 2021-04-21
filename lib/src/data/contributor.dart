/// A class that defines and creates each Contributor for ContributorCard.
class Contributor {
	/// Creates a list of Contributors to be given to ContributorCard.
	/// 
	/// The most recent contributors go at the top of the list.
	static const List<Contributor> contributors = [
		Contributor(
			name: "David T.",
			gradYear: "'23",
			title: "Frontend",
			email: "tarrabd@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Placeholder"
		),
		Contributor(
			name: "Brayden K.",
			gradYear: "'23",
			title: "Backend",
			email: "kohlerb@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Placeholder"
		),
		Contributor(
			name: "Joshua T.",
			gradYear: "'23",
			title: "Middleware and Apple Expert",
			email: "todesj@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Placeholder"
		),
		Contributor(
			name: "Levi L.",
			gradYear: "'21",
			title: "Biggest Boi",
			email: "leschesl@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Placeholder"
		),
		Contributor(
			name: "Mr. Vovsha",
			gradYear: "'21",
			title: "Mentor",
			email: "evovsha@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "Placeholder"
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
	/// Non-Ramaz email
	final String email;
	/// The contributor's description.
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
