// src/modules/user/user.repository.ts
import { PrismaClient ,User} from '../generated/prisma'

const prisma = new PrismaClient();

export class UserRepository {

  

  async findByUID(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async findAll(): Promise<User[]> {
    return prisma.user.findMany();
  }
}
