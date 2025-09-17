import { PrismaClient ,User} from '../generated/prisma'

const prisma = new PrismaClient();

export class UserRepository {

  
 async createUser(id:string,name:string){
    return prisma.user.create({data:{
      id,
      name
    }})
  }


  async findByUID(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async findAll(): Promise<User[]> {
    return prisma.user.findMany();
  }
}
