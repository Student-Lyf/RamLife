const firebase = require("@firebase/testing");
const fs = require("fs");

/*
 * ============
 *    Setup
 * ============
 */
const projectId = "firestore-emulator-example";
const firebasePort = require("../firebase.json").emulators.firestore.port;
const port = firebasePort /** Exists? */ ? firebasePort : 8080;
const coverageUrl = `http://localhost:${port}/emulator/v1/projects/${projectId}:ruleCoverage.html`;
const adminApp = firebase
  .initializeAdminApp({projectId})
  .firestore()

const rules = fs.readFileSync("firestore.rules", "utf8");

/**
 * Creates a new app with authentication data matching the input.
 *
 * @param {object} auth the object to use for authentication (typically {uid: some-uid})
 * @return {object} the app.
 */
function authedApp(auth) {
  return firebase.initializeTestApp({ projectId, auth }).firestore();
}

/*
 * ============
 *  Test Cases
 * ============
 */
beforeEach(async () => {
  // Clear the database between tests
  await firebase.clearFirestoreData({ projectId });
});

before(async () => {
  await firebase.loadFirestoreRules({ projectId, rules });
});

after(async () => {
  await Promise.all(firebase.apps().map(app => app.delete()));
  console.log(`View rule coverage information at ${coverageUrl}\n`);
});

describe("Ramaz Student Life app", function() {
  const email = "some_email";
  const uid = "123";
  const auth = {email: email, uid: uid};

  describe("Student test", function() {
    it("Should not allow creating new users", async () => {
      const db = authedApp(null);
      const students = db.collection("students");
      const newStudent = students.doc("new");

      await firebase.assertFails(newStudent.set({"this": "is"}));
    });

    it("Should not be able to get other students' documents", async () => {
      const alice = "alice";
      const bob = "bob";
      const db = authedApp({email: alice, uid: uid});
      const students = db.collection("students");

      await firebase.assertSucceeds(students.doc(alice).get())
      await firebase.assertFails(students.doc(bob).get());
    });

    it("Only admins can edit schedules", async () => {
      const authed = authedApp({email: email, uid: uid, "scopes": ["schedules"]});
      const notEnoughPermissions = authedApp({email: email, uid: uid, "scopes": ["calendar"]});
      const notAuthed = authedApp(null);
      const students = "students";
      const student = "randomStudent";
      const data = {"random": "data"};

      await firebase.assertSucceeds(
        authed.collection(students)
          .doc(student)
          .set(data)
      );
      await firebase.assertFails(
        notEnoughPermissions.collection(students)
          .doc(student)
          .set(data)
      );
      await firebase.assertFails(
        notAuthed.collection(students)
          .doc(student)
          .set(data)
      );
    });
  });

  describe("Subject test", function() {
    const data = {"some": "data"};
    const subject_id = "SOME_SUBJECT_ID";
    classes = "classes";

    it("Cannot create or delete subjects", async () => {
      await firebase.assertFails(
        authedApp(null)
          .collection(classes)
          .doc(subject_id)
          .set(data)
      );

      await firebase.assertFails(
        authedApp(null)
          .collection(classes)
          .doc(subject_id)
          .delete()
      );
    });

    it("Only authed users can access subject data", async () => {
      await firebase.assertFails(
        authedApp(null)
          .collection(classes)
          .doc(subject_id)
          .get()
      );
      await firebase.assertSucceeds(
        authedApp({email: email, uid: uid})
          .collection(classes)
          .doc(subject_id)
          .get()
      );
    });

    it("Only admins can change subject data", async () => {
      await firebase.assertFails(
        authedApp(null)
          .collection(classes)
          .doc(subject_id)
          .set(data)
      );

      await firebase.assertSucceeds(
        authedApp({email: email, uid: uid, "scopes": ["subjects"]})
          .collection(classes)
          .doc(subject_id)
          .set(data)
      );

      await firebase.assertFails(
        authedApp({email: email, uid: uid, "scopes": ["calendar"]})
          .collection(classes)
          .doc(subject_id)
          .set(data)
      );
    });
  });

  describe("Feedback test", function() {
    const feedback = authedApp(null).collection("feedback").doc("1");
    const data = {"message": "hello"};

    it("Anyone can send feedback", async () => {
      await firebase.assertSucceeds(
        feedback.set(data)
      );
    });

    it ("Nobody can read feedback", async () => {
      await firebase.assertFails(
        feedback.get()
      )
    });
  });

  describe("Calendar", function() {
    const notAuthed = authedApp(null);
    const authed = authedApp(auth);
    const withPermission = authedApp({uid: uid, "scopes": ["calendar"]})
    const withoutPermission = authedApp({uid: uid, "scopes": ["schedules"]})
    const calendar = "calendar"
    const jan = "1"
    const data = {"this is": "data"}

    it("Nobody can create or delete in the calendar", async () => {
      await firebase.assertFails(
        withPermission.collection(calendar).doc("doc").set(data)
      )

      await firebase.assertFails(
        withPermission.collection(calendar).doc(jan).delete()
      );
    })

    it("Anyone can access the calendar", async () => {
      await firebase.assertFails(
        notAuthed.collection(calendar).doc(jan).get()
      );

      await firebase.assertSucceeds(
        authed.collection(calendar).doc(jan).get()
      );
    })

    it("Only admins can edit the calendar", async () => {
      await firebase.assertFails(
        authed.collection(calendar).doc(jan).set(data)
      )

      await firebase.assertFails(
        withoutPermission.collection(calendar).doc(jan).set(data)
      )

      // Make sure we are not creating
      await adminApp
        .collection(calendar)
        .doc(jan)
        .set({"some": "data"})

      await firebase.assertSucceeds(
        withPermission.collection(calendar).doc(jan).set(data)
      )
    })
  })

  describe("Notes", () => {
    const notAuthed = authedApp(null)
    const authed = authedApp(auth)
    const notes = "notes"
    const note = email  // must match email

    it("Only access own notes", async () => {
      await firebase.assertFails(
        notAuthed
          .collection(notes)
          .doc(note)
          .get()
      )

      await firebase.assertSucceeds(
        authed.collection(notes).doc(note).get()
      )
    })
  })

  describe("Admins", () => {
    const admins = "admin"
    const notAuthed = authedApp(null)
    const authed = authedApp(auth)
    const doc = email

    it("Only access own data", async () => {
      await firebase.assertFails(
        notAuthed.collection(admins).doc(doc).get()
      )

      await firebase.assertSucceeds(
        authed.collection(admins).doc(doc).get()
      )
    })

    it("Cannot update permissions", async () => {
      await adminApp
        .collection(admins)
        .doc(doc)
        .set({"scopes": ["calendar"]})

      await firebase.assertFails(
        authed.collection(admins).doc(doc).set({
          "scopes": ["calendar", "schedule"]  // added permission
        })
      )

      await firebase.assertSucceeds(
        authed.collection(admins).doc(doc).set({
          "scopes": ["calendar"],
          "other": "data",
        })
      )
    })
  })
});