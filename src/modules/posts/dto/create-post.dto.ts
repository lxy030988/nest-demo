import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsInt,
} from 'class-validator';

export class CreatePostDto {
  @IsString()
  @IsNotEmpty()
  readonly title: string;

  @IsString()
  @IsOptional()
  readonly content?: string;

  @IsInt()
  readonly authorId: number;

  @IsOptional()
  @IsBoolean()
  readonly published?: boolean;
}
