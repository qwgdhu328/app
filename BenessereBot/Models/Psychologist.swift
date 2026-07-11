import Foundation

struct Psychologist: Identifiable, Codable {
    let id: UUID
    let name: String
    let specialty: String
    let city: String
    let address: String
    let phone: String
    let email: String
    let description: String
    let imageSystemName: String

    init(name: String, specialty: String, city: String, address: String, phone: String, email: String, description: String, imageSystemName: String = "person.crop.circle.fill") {
        self.id = UUID()
        self.name = name
        self.specialty = specialty
        self.city = city
        self.address = address
        self.phone = phone
        self.email = email
        self.description = description
        self.imageSystemName = imageSystemName
    }
}

let samplePsychologists: [Psychologist] = [
    Psychologist(
        name: "Dott.ssa Maria Rossi",
        specialty: "Psicoterapia Cognitivo-Comportamentale",
        city: "Milano",
        address: "Via della Moscova 12, Milano",
        phone: "02 1234567",
        email: "m.rossi@psicologi.it",
        description: "Specializzata in disturbi d'ansia e depressione. Offre sedute online e in presenza."
    ),
    Psychologist(
        name: "Dott. Luca Bianchi",
        specialty: "Psicologia Clinica",
        city: "Roma",
        address: "Via dei Gracchi 45, Roma",
        phone: "06 7654321",
        email: "l.bianchi@psicologi.it",
        description: "Esperto in terapia di coppia e sostegno genitoriale. Approccio integrato."
    ),
    Psychologist(
        name: "Dott.ssa Anna Verdi",
        specialty: "Neuropsicologia",
        city: "Torino",
        address: "Corso Vittorio Emanuele 88, Torino",
        phone: "011 9876543",
        email: "a.verdi@psicologi.it",
        description: "Valutazione e riabilitazione neuropsicologica. Disturbi dell'apprendimento."
    ),
    Psychologist(
        name: "Dott. Marco Gialli",
        specialty: "Psicologia dello Sport",
        city: "Bologna",
        address: "Via Indipendenza 33, Bologna",
        phone: "051 2468135",
        email: "m.gialli@psicologi.it",
        description: "Mental coaching e gestione dell'ansia da prestazione. Atleti e professionisti."
    ),
    Psychologist(
        name: "Dott.ssa Elena Neri",
        specialty: "Psicoterapia Psicodinamica",
        city: "Firenze",
        address: "Piazza della Signoria 7, Firenze",
        phone: "055 3692581",
        email: "e.neri@psicologi.it",
        description: "Terapia individuale e di gruppo. Disturbi dell'umore e crescita personale."
    ),
    Psychologist(
        name: "Dott. Paolo Azzurri",
        specialty: "Psicologia dell'Emergenza",
        city: "Napoli",
        address: "Via Toledo 156, Napoli",
        phone: "081 1472583",
        email: "p.azzurri@psicologi.it",
        description: "Supporto in situazioni di crisi e trauma. Gestione dello stress acuto."
    )
]
