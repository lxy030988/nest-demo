import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
} from '@nestjs/common';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  /**
   * 创建文章
   * POST /posts
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createPostDto: CreatePostDto) {
    return this.postsService.create(createPostDto);
  }

  /**
   * 获取所有文章
   * GET /posts
   */
  @Get()
  findAll() {
    return this.postsService.findAll();
  }

  /**
   * 获取指定作者的所有文章
   * GET /posts/author/:authorId
   */
  @Get('author/:authorId')
  findByAuthor(@Param('authorId', ParseIntPipe) authorId: number) {
    return this.postsService.findByAuthor(authorId);
  }

  /**
   * 获取单个文章
   * GET /posts/:id
   */
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.postsService.findOne(id);
  }

  /**
   * 更新文章
   * PATCH /posts/:id
   */
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updatePostDto: UpdatePostDto,
  ) {
    return this.postsService.update(id, updatePostDto);
  }

  /**
   * 删除文章
   * DELETE /posts/:id
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.postsService.remove(id);
  }
}
