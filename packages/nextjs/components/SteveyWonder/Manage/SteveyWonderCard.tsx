import React from "react";
import { ShowSteveyTokenURI } from "./ShowSteveyTokenURI";
import { useAccount } from "wagmi";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type Props = {
  id: bigint;
};

export const SteveyWonderCard = ({ id }: Props) => {
  const { address } = useAccount();

  const { data: tokenId, isLoading } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenOfOwnerByIndex",
    args: [address, id],
    watch: true,
  });

  return (
    <div>
      {isLoading ? (
        <div>Loading...</div>
      ) : (
        <>
          <div className="border border-gray-300 rounded-md px-2 bg-blue-950">
            <ShowSteveyTokenURI tokenId={tokenId as bigint} />
          </div>
        </>
      )}
    </div>
  );
};
