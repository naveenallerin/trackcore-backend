export interface JobBoardProvider {
  name: string;
  searchJobs(query: string): Promise<JobSearchResult[]>;
  postJob(job: JobPostData): Promise<boolean>;
}

export interface JobSearchResult {
  id: string;
  title: string;
  company: string;
  location: string;
  description: string;
  url: string;
  salary?: string;
  postedDate: Date;
  source: string;
}

export interface JobPostData {
  title: string;
  description: string;
  company: string;
  location: string;
  salary?: string;
  requirements: string[];
}
