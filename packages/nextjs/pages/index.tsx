import type { NextPage } from "next";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-3xl mb-10">Bring your imagination to life! Design your own</span>
            <span className="block text-4xl font-bold mb-10">Stevey Wonder</span>
            <span className="block text-2xl mb-2">and dress them in your favorite styles.</span>
            <button></button>
          </h1>
        </div>
      </div>
    </>
  );
};

export default Home;
