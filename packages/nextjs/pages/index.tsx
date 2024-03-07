import Image from "next/image";
import Link from "next/link";
import type { NextPage } from "next";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      <MetaHeader />
      <div className="flex flex-1 justify-center items-center gap-32">
        <Image src="/images/wonder.png" width={500} height={500} alt="stevey-wonder" />
        <div className="flex flex-col gap-4">
          <div className="text-6xl leading-[4.375rem] font-medium">
            <h1>Design your very own</h1>
            <h1 className="bg-gradient-to-r from-[#8085FF] from-[-2%] via-white via-[32%] to-[#F59595] to-[67%] font-bold bg-clip-text text-transparent">
              Stevey Wonder
            </h1>
          </div>
          <div className="flex flex-col text-[#AEC1E0] font-normal text-2xl">
            <span>Sed ut perspiciatis unde omnis iste natus error</span>
            <span>sit voluptatem accusantium doloremque laudantium, to</span>
          </div>
          <Link
            href="/steveywonder"
            className="px-4 py-6 rounded-lg cursor-pointer bg-[#3C44FF] font-medium text-xl max-w-fit my-4"
          >
            Mint Stevey Wonder
          </Link>
        </div>
      </div>
    </>
  );
};

export default Home;
