import { useEffect } from "react";
import { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { MintStevey } from "~~/components/steveywonder";
import { SteveyWonderCard } from "~~/components/steveywonder/main/SteveyWonderCard";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

const SteveyWonder: NextPage = () => {
  const { address } = useAccount();

  const { data: balanceOfStevey } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "balanceOf",
    args: [address],
    watch: true,
  });

  useEffect(() => {
    console.log(balanceOfStevey);
  }, [balanceOfStevey]);

  return (
    <div>
      <MetaHeader title="SteveyWonder" />
      {balanceOfStevey === undefined ? (
        <div className="flex justify-center items-center h-[80vh]">
          <span className="loading loading-spinner loading-lg"></span>
        </div>
      ) : Number(balanceOfStevey) > 0 ? (
        <SteveyWonderNFTs balanceOfStevey={balanceOfStevey} />
      ) : (
        <NoSteveyWonderNFTs />
      )}
    </div>
  );
};

type SteveyWonderNFTsProps = {
  balanceOfStevey: bigint | undefined;
};

const SteveyWonderNFTs = ({ balanceOfStevey }: SteveyWonderNFTsProps) => {
  return (
    <div className="flex flex-col my-6 p-2 gap-y-8">
      <div className="flex flex-row flex-1 justify-between items-center px-10 py-2 md:px-20 lg:px-30">
        <span className="text-3xl font-bold">Stevey Wonders&apos;</span>
        <MintStevey name="Mint" className="text-lg py-2" />
      </div>
      <div className="px-14 space-y-5 md:grid md:space-y-0 md:grid-cols-2 md:px-24 md:gap-10 lg:grid-cols-3 lg:px-36 xl:grid-cols-4">
        {[...Array(Number(balanceOfStevey))].map((_, index) => {
          return <SteveyWonderCard idx={BigInt(index)} key={index} />;
        })}
      </div>
    </div>
  );
};

const NoSteveyWonderNFTs = () => {
  return (
    <div className="flex flex-col flex-1 items-center justify-center gap-6 h-[80vh]">
      <div className="text-2xl">No Stevey Wonder!</div>
      <MintStevey name="Mint Stevey Wonder" className="text-xl" />
    </div>
  );
};

export default SteveyWonder;
