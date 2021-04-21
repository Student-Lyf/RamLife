/// A class that defines and creates each Contributor for ContributorCard.
class Contributor {
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
			title: "Middleend and Apple Expert",
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

	final String name;
	/// This can be years worked at Ramaz (for faculty)
	final String gradYear;
	final String title;
	/// Non-Ramaz email
	final String email;
	final String description;
	final String imageName;

	const Contributor({
		required this.description,
		required this.gradYear,
		required this.email,
		required this.name,
		required this.title,
		required this.imageName,
	});
	
}
