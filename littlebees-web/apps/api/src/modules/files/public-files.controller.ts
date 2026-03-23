import {
  Controller,
  Get,
  Param,
  Query,
  Res,
} from '@nestjs/common';
import { Response } from 'express';
import { FilesService } from './files.service';

@Controller('files/public')
export class PublicFilesController {
  constructor(private readonly filesService: FilesService) {}

  @Get(':id')
  async view(
    @Param('id') id: string,
    @Query('expires') expires: string,
    @Query('signature') signature: string,
    @Res() res: Response,
  ) {
    const file = await this.filesService.getPublicFile(id, expires, signature);

    res.setHeader('Content-Type', file.mimeType);
    res.setHeader('Content-Length', String(file.buffer.length));
    res.setHeader('Cache-Control', 'private, max-age=300');
    res.setHeader(
      'Content-Disposition',
      `inline; filename="${encodeURIComponent(file.filename)}"`,
    );

    res.send(file.buffer);
  }
}
