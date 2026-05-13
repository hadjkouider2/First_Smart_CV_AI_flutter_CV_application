class CVProfile {
  String fullName;
  String jobTitle;
  String email;
  String phone;
  String location;
  String summary;
  String experience;
  String skills;
  String education;
  String languages;
  String website;
  String github;
  String linkedin;

  CVProfile({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.summary = '',
    this.experience = '',
    this.skills = '',
    this.education = '',
    this.languages = '',
    this.website = '',
    this.github = '',
    this.linkedin = '',
  });

  CVProfile copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? summary,
    String? experience,
    String? skills,
    String? education,
    String? languages,
    String? website,
    String? github,
    String? linkedin,
  }) {
    return CVProfile(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      website: website ?? this.website,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'summary': summary,
      'experience': experience,
      'skills': skills,
      'education': education,
      'languages': languages,
      'website': website,
      'github': github,
      'linkedin': linkedin,
    };
  }

  factory CVProfile.fromMap(Map<String, dynamic> map) {
    return CVProfile(
      fullName: map['fullName'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      summary: map['summary'] ?? '',
      experience: map['experience'] ?? '',
      skills: map['skills'] ?? '',
      education: map['education'] ?? '',
      languages: map['languages'] ?? '',
      website: map['website'] ?? '',
      github: map['github'] ?? '',
      linkedin: map['linkedin'] ?? '',
    );
  }
}

enum TemplateType { 
  modern, minimalist, corporate, 
  creative, darkElegant, gradient, 
  sidebar, minimalChic, techInnovator 
}
