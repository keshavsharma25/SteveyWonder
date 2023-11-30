import { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { ShowSteveyTokenURI } from "~~/components/SteveyWonder/ShowSteveyTokenURI";
import { useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

const SteveyWonder: NextPage = () => {
  const { address } = useAccount();

  const { data: balanceOfStevey } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "balanceOf",
    args: [address],
  });

  const { write: writeSafeMintStevey } = useScaffoldContractWrite({
    contractName: "SteveyWonder",
    functionName: "safeMint",
  });

  const { data: tokenId } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenOfOwnerByIndex",
    args: [address, BigInt(0)],
  });

  return (
    <>
      <MetaHeader title="SteveyWonder" />
      {Number(balanceOfStevey) > 0 ? (
        <div className="flex items-center justify-center">
          <div className="text-center">
            <ShowSteveyTokenURI tokenId={tokenId as bigint} />
            <div className="font-sans text-2xl">STEVEY WONDER #{Number(tokenId)}</div>
          </div>
          {/* <div className="flex flex-1 justify-center"> */}
          {/* {tokenId !== undefined && <ShowTShirts tokenId={tokenId as bigint} />} */}
          {/* </div> */}
        </div>
      ) : (
        <div className="flex items-center justify-center h-80">
          <button
            onClick={() => {
              writeSafeMintStevey?.();
            }}
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Mint Stevey Wonder
          </button>
        </div>
      )}
    </>
  );
};

export default SteveyWonder;
