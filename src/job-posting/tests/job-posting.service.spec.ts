import { Test, TestingModule } from '@nestjs/testing';
import { JobPostingService } from '../job-posting.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JobPosting } from '../entities/job-posting.entity';
import { Repository } from 'typeorm';
import { CreateJobPostingDto } from '../dto/create-job-posting.dto';
import { UpdateJobPostingDto } from '../dto/update-job-posting.dto';

describe('JobPostingService', () => {
  let service: JobPostingService;
  let repository: Repository<JobPosting>;

  const mockJobPosting = {
    id: 1,
    title: 'Software Engineer',
    description: 'Test description',
    requirements: ['JavaScript', 'TypeScript'],
    location: 'Remote',
    salary: '100000',
    company: 'Test Company',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockRepository = {
    create: jest.fn().mockImplementation(dto => dto),
    save: jest.fn().mockResolvedValue(mockJobPosting),
    find: jest.fn().mockResolvedValue([mockJobPosting]),
    findOne: jest.fn().mockResolvedValue(mockJobPosting),
    update: jest.fn().mockResolvedValue({ affected: 1 }),
    delete: jest.fn().mockResolvedValue({ affected: 1 }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        JobPostingService,
        {
          provide: getRepositoryToken(JobPosting),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<JobPostingService>(JobPostingService);
    repository = module.get<Repository<JobPosting>>(getRepositoryToken(JobPosting));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a job posting', async () => {
      const createDto: CreateJobPostingDto = {
        title: 'Software Engineer',
        description: 'Test description',
        requirements: ['JavaScript', 'TypeScript'],
        location: 'Remote',
        salary: '100000',
        company: 'Test Company',
      };

      const result = await service.create(createDto);
      expect(result).toEqual(mockJobPosting);
      expect(repository.create).toHaveBeenCalledWith(createDto);
      expect(repository.save).toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return an array of job postings', async () => {
      const result = await service.findAll();
      expect(result).toEqual([mockJobPosting]);
      expect(repository.find).toHaveBeenCalled();
    });
  });

  describe('findOne', () => {
    it('should return a job posting by id', async () => {
      const result = await service.findOne(1);
      expect(result).toEqual(mockJobPosting);
      expect(repository.findOne).toHaveBeenCalledWith({ where: { id: 1 } });
    });
  });

  describe('update', () => {
    it('should update a job posting', async () => {
      const updateDto: UpdateJobPostingDto = {
        title: 'Updated Title',
      };

      const result = await service.update(1, updateDto);
      expect(result).toEqual({ affected: 1 });
      expect(repository.update).toHaveBeenCalledWith(1, updateDto);
    });
  });

  describe('remove', () => {
    it('should delete a job posting', async () => {
      const result = await service.remove(1);
      expect(result).toEqual({ affected: 1 });
      expect(repository.delete).toHaveBeenCalledWith(1);
    });
  });
});
