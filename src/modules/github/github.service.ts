import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

export interface GithubUser {
  login: string;
  id: number;
  avatar_url: string;
  name: string;
  bio: string;
  location: string;
  email: string;
  public_repos: number;
  public_gists: number;
  followers: number;
  following: number;
  created_at: string;
  updated_at: string;
  html_url: string;
}

@Injectable()
export class GithubService {
  constructor(private readonly httpService: HttpService) {}

  async getUserInfo(username: string): Promise<GithubUser> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<GithubUser>(
          `https://api.github.com/users/${username}`,
          {
            headers: {
              Accept: 'application/vnd.github.v3+json',
              'User-Agent': 'NestJS-Lambda-App',
            },
          },
        ),
      );

      return response.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new HttpException(
          `GitHub user '${username}' not found`,
          HttpStatus.NOT_FOUND,
        );
      }

      throw new HttpException(
        'Failed to fetch data from GitHub API',
        HttpStatus.BAD_GATEWAY,
      );
    }
  }
}
