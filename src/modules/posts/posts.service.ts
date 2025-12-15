import { Injectable, NotFoundException } from '@nestjs/common';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { Post } from './entities/post.entity';

@Injectable()
export class PostsService {
  private posts: Post[] = [];
  private idCounter = 1;

  /**
   * 创建新文章
   */
  create(createPostDto: CreatePostDto): Post {
    const post = new Post({
      id: String(this.idCounter++),
      ...createPostDto,
      published: createPostDto.published ?? false,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    this.posts.push(post);
    return post;
  }

  /**
   * 获取所有文章
   */
  findAll(): Post[] {
    return this.posts;
  }

  /**
   * 获取已发布的文章
   */
  findPublished(): Post[] {
    return this.posts.filter((post) => post.published);
  }

  /**
   * 根据作者 ID 获取文章
   */
  findByAuthor(authorId: string): Post[] {
    return this.posts.filter((post) => post.authorId === authorId);
  }

  /**
   * 根据 ID 获取文章
   */
  findOne(id: string): Post {
    const post = this.posts.find((p) => p.id === id);
    if (!post) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }
    return post;
  }

  /**
   * 更新文章
   */
  update(id: string, updatePostDto: UpdatePostDto): Post {
    const post = this.findOne(id);
    Object.assign(post, updatePostDto, { updatedAt: new Date() });
    return post;
  }

  /**
   * 删除文章
   */
  remove(id: string): void {
    const index = this.posts.findIndex((p) => p.id === id);
    if (index === -1) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }
    this.posts.splice(index, 1);
  }
}
