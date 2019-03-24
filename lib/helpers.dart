import "package:flutter/material.dart";
import "dataclasses.dart";
import "mock.dart" show getSubjectByID;  // belongs here but is a mock...

String aOrAn (String nextWord) => 
	["a", "e", "i", "o", "u"].contains (
		nextWord [0].toLowerCase()
	) 
		? "n"
		: "";

List <Widget> pad ({List <Widget> children, double padding}) => children.map (
	(Widget child) => Padding (
		padding: EdgeInsets.symmetric(vertical: padding),
		child: child
	)
).toList();
	
Subject getSubject (Period period) => period == null 
	? null 
	: getSubjectByID (period.id);