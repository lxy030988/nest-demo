import { Controller, Get, Res, NotFoundException } from '@nestjs/common';
import type { Response } from 'express';
import { join } from 'path';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getIndex(@Res() res: Response): void {
    // 返回 HTML 首页文件
    res.sendFile(join(__dirname, '..', 'public', 'index.html'));
  }

  @Get('api')
  getHello(): string {
    return this.appService.getHello();
  }

  // 通配符路由 - 捕获所有未匹配的路由
  @Get('*')
  handleNotFound() {
    throw new NotFoundException('Page not found');
  }
}
