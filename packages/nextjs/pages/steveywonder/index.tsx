import { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { MintStevey } from "~~/components/SteveyWonder";
import { SteveyWonderCard } from "~~/components/SteveyWonder/Manage/SteveyWonderCard";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

const SteveyWonder: NextPage = () => {
  const { address } = useAccount();

  const { data: balanceOfStevey, isLoading } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "balanceOf",
    args: [address],
  });

  return (
    <>
      <MetaHeader title="SteveyWonder" />
      {isLoading ? (
        <div>Loading...</div>
      ) : Number(balanceOfStevey) > 0 ? (
        <div className="grid-flow-row grid-col-2 gap-10 mt-10 px-10">
          {[...Array(Number(balanceOfStevey))].map((_, index) => {
            console.log("id:", index);
            return <SteveyWonderCard id={BigInt(index)} key={index} />;
          })}
        </div>
      ) : (
        <div className="flex flex-col flex-1 items-center justify-center gap-6">
          <div className="text-2xl">No Stevey Wonder!</div>
          <MintStevey name="Mint" className="" />
        </div>
      )}
    </>
  );
};

export default SteveyWonder;
