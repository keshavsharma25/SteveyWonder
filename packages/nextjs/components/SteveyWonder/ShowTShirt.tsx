import React, { useEffect, useState } from "react";
import Image from "next/image";
import { Address } from "viem";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type Props = {
  index: number;
  tba: Address;
  activeTShirt: number;
};

export const ShowTShirt = ({ index, tba }: Props) => {
  const [tokenURI, setTokenURI] = useState<string>("");

  const { data: tokenId } = useScaffoldContractRead({
    contractName: "TShirt",
    functionName: "tokenOfOwnerByIndex",
    args: [tba, BigInt(index)],
  });

  const { data: tokenURITShirt } = useScaffoldContractRead({
    contractName: "TShirt",
    functionName: "tokenURI",
    args: [tokenId],
  });

  useEffect(() => {
    let _tokenURITShirt = tokenURITShirt?.toString();
    _tokenURITShirt = _tokenURITShirt?.split("data:application/json;base64,")[1];

    if (tokenURITShirt !== undefined) {
      const jsonString = Buffer.from(_tokenURITShirt as string, "base64").toString("utf-8");
      const parseTokenURI = JSON.parse(jsonString);
      setTokenURI(parseTokenURI.image);
    }
  }, [tokenURITShirt]);

  return (
    <div className="">
      <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt="SteveyWonder Token" width={200} height={200} />
    </div>
  );
};
