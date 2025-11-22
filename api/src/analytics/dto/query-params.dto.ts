import { IsOptional, IsString, IsInt, Min, Max, IsIn } from 'class-validator'
import { Type } from 'class-transformer'

export class TopAuthorsQueryDto {
  @IsOptional()
  @IsIn(['30d', '60d', '90d'])
  period?: string = '30d'

  @IsOptional()
  @IsString()
  category?: string

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20
}

export class TimePatternQueryDto {
  @IsOptional()
  @IsIn(['30d', '60d', '90d'])
  period?: string = '90d'

  @IsOptional()
  @IsString()
  category?: string
}

export class OpportunityQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  minPosts?: number = 5

  @IsOptional()
  @IsString()
  category?: string
}

export class TrendQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(90)
  days?: number = 7
}
