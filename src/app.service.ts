import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return '🚀 WizePick API - Sistema de Control de Inventarios Multi-Negocio está funcionando correctamente!';
  }
}
