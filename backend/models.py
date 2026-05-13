from sqlalchemy import Column, Integer, String, Text
from database import Base

class CVProfile(Base):
    __tablename__ = "cv_profiles"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, index=True)
    job_title = Column(String, index=True)
    summary = Column(Text)
    experience = Column(Text)
    education = Column(Text)
    skills = Column(Text)
