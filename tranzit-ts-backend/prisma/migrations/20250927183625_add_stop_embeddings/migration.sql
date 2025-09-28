-- CreateTable
CREATE TABLE "public"."StopEmbedding" (
    "id" SERIAL NOT NULL,
    "stopId" INTEGER NOT NULL,
    "vector" DOUBLE PRECISION[],

    CONSTRAINT "StopEmbedding_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "StopEmbedding_stopId_key" ON "public"."StopEmbedding"("stopId");

-- CreateIndex
CREATE INDEX "StopEmbedding_stopId_idx" ON "public"."StopEmbedding"("stopId");

-- AddForeignKey
ALTER TABLE "public"."StopEmbedding" ADD CONSTRAINT "StopEmbedding_stopId_fkey" FOREIGN KEY ("stopId") REFERENCES "public"."Stop"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
